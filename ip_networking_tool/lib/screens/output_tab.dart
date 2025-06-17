import 'package:flutter/material.dart';
import '../utils/history_storage.dart';
import '../utils/export_to_csv.dart';

class OutputTab extends StatefulWidget {
  const OutputTab({super.key});

  @override
  State<OutputTab> createState() => _OutputTabState();
}

class _OutputTabState extends State<OutputTab> {
  String _sortColumn = 'LAN'; // Default sort column
  bool _sortAscending = true; // Default sort order
  int? _selectedHistoryIndex; // Selected history entry
  String _searchQuery = ''; // Search query for filtering
  int _currentPage = 0; // Current page for pagination
  final int _rowsPerPage = 10; // Rows per page

  // Numerical IP address comparison
  int _compareIp(String ip1, String ip2) {
    final octets1 = ip1.split('.').map(int.parse).toList();
    final octets2 = ip2.split('.').map(int.parse).toList();
    for (int i = 0; i < 4; i++) {
      final comparison = octets1[i].compareTo(octets2[i]);
      if (comparison != 0) return comparison;
    }
    return 0;
  }

  // Sorting function
  List<Map<String, dynamic>> _sortSubnets(List<Map<String, dynamic>> subnets, String column, bool ascending) {
    final sorted = List<Map<String, dynamic>>.from(subnets);
    sorted.sort((a, b) {
      dynamic aValue, bValue;
      if (column == 'LAN') {
        aValue = subnets.indexOf(a) + 1;
        bValue = subnets.indexOf(b) + 1;
      } else if (column == 'network_address' || column == 'broadcast_address') {
        aValue = a[column];
        bValue = b[column];
        final comparison = _compareIp(aValue, bValue);
        return ascending ? comparison : -comparison;
      } else if (column == 'prefixlen') {
        aValue = int.parse(a[column].toString());
        bValue = int.parse(b[column].toString());
      } else {
        aValue = a[column];
        bValue = b[column];
      }
      final comparison = aValue.toString().compareTo(bValue.toString());
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  // Filter subnets based on search query
  List<Map<String, dynamic>> _filterSubnets(List<Map<String, dynamic>> subnets, String query) {
    if (query.isEmpty) return subnets;
    final lowerQuery = query.toLowerCase();
    return subnets.where((subnet) {
      return subnet['network_address'].toLowerCase().contains(lowerQuery) ||
          subnet['broadcast_address'].toLowerCase().contains(lowerQuery) ||
          subnet['usable_ips'].toLowerCase().contains(lowerQuery) ||
          subnet['netmask'].toLowerCase().contains(lowerQuery) ||
          '/${subnet['prefixlen']}'.contains(lowerQuery);
    }).toList();
  }

  // Export all history entries to a single CSV
  Future<void> _exportAllHistory(List<Map<String, dynamic>> history) async {
    for (var entry in history) {
      await exportToCsv(entry);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All history exported to CSV files')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HistoryStorage.getHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No calculations yet.'));
        }

        final history = snapshot.data!;
        final latest = history[_selectedHistoryIndex ?? history.length - 1];
        final network = latest['network'];
        final bitwiseResult = latest['bitwiseResult'] as Map<String, dynamic>?;
        final subnets = latest['subnets'] as List<Map<String, dynamic>>;
        final filteredSubnets = _filterSubnets(subnets, _searchQuery);
        final sortedSubnets = _sortSubnets(filteredSubnets, _sortColumn, _sortAscending);
        final pageCount = (sortedSubnets.length / _rowsPerPage).ceil();
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage).clamp(0, sortedSubnets.length);
        final displayedSubnets = sortedSubnets.sublist(startIndex, endIndex);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Network: $network',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  DropdownButton<int>(
                    hint: const Text('Select History'),
                    value: _selectedHistoryIndex,
                    items: history.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('Calc ${index + 1}: ${item['input']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHistoryIndex = value;
                        _currentPage = 0; // Reset pagination
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search Subnets',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0; // Reset pagination
                  });
                },
              ),
              const SizedBox(height: 16),
              if (bitwiseResult != null) ...[
                Text(
                  'Bitwise Result:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text('  Binary: ${bitwiseResult['binary']}'),
                Text('  IP: ${bitwiseResult['ip']}'),
                const SizedBox(height: 16),
              ],
              if (subnets.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subnets (${filteredSubnets.length}):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await exportToCsv(latest);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Exported to CSV')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          child: const Text('Export Selected'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: history.isNotEmpty
                              ? () async => await _exportAllHistory(history)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                          ),
                          child: const Text('Export All'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    dataRowMaxHeight: 48,
                    border: TableBorder.all(color: theme.colorScheme.outline),
                    columns: [
                      DataColumn(
                        label: const Text('LAN', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumn = 'LAN';
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Network Address', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumn = 'network_address';
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Broadcast Address', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumn = 'broadcast_address';
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Usable IPs', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumn = 'usable_ips';
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Subnet Mask', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumn = 'netmask';
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('CIDR', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumn = 'prefixlen';
                            _sortAscending = ascending;
                          });
                        },
                      ),
                    ],
                    rows: displayedSubnets.asMap().entries.map((entry) {
                      final i = entry.key + startIndex + 1;
                      final subnet = entry.value;
                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>((states) {
                          return i % 2 == 0 ? theme.colorScheme.surfaceContainerLow : null;
                        }),
                        cells: [
                          DataCell(Text('LAN $i')),
                          DataCell(Text(subnet['network_address'])),
                          DataCell(Text(subnet['broadcast_address'])),
                          DataCell(Text(subnet['usable_ips'])),
                          DataCell(Text(subnet['netmask'])),
                          DataCell(Text('/${subnet['prefixlen']}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                if (pageCount > 1) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                      ),
                      Text('Page ${_currentPage + 1} of $pageCount'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < pageCount - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}