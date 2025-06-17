import 'package:flutter/material.dart';
import '../utils/ip_utils.dart';
import '../utils/history_storage.dart';

class InputTab extends StatefulWidget {
  const InputTab({super.key});

  @override
  State<InputTab> createState() => _InputTabState();
}

class _InputTabState extends State<InputTab> {
  final _ipController = TextEditingController();
  String _operation = 'None';
  String _mode = 'None';
  int _numLans = 1;
  String? _errorMessage;

  void _processInput() async {
    try {
      final ipInput = _ipController.text.trim();
      final network = parseInput(ipInput);
      Map<String, dynamic>? bitwiseResult;
      List<Map<String, dynamic>> subnets = [];

      if (_operation != 'None') {
        final result = bitwiseOperation(
          network['network_address']!,
          network['netmask']!,
          _operation,
        );
        bitwiseResult = {
          'binary': result['binary'],
          'ip': result['ip'],
        };
      }

      if (_mode == 'Manual') {
        subnets = calculateLans(network['network']!, _numLans);
      } else if (_mode == 'Auto') {
        subnets = calculateLans(network['network']!, null);
      }

      // Save to history
      await HistoryStorage.saveHistory({
        'input': ipInput,
        'operation': _operation,
        'mode': _mode,
        'numLans': _numLans,
        'network': network.toString(),
        'subnets': subnets,
        'bitwiseResult': bitwiseResult,
      });

      setState(() {
        _errorMessage = null;
      });

      // Navigate to OutputTab (optional, can be handled via state management)
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: 'Enter IP (IP/mask, IP/CIDR, IP only)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _operation,
            onChanged: (value) => setState(() => _operation = value!),
            items: ['None', 'AND', 'OR']
                .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                .toList(),
            hint: const Text('Select Bitwise Operation'),
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _mode,
            onChanged: (value) => setState(() => _mode = value!),
            items: ['None', 'Manual', 'Auto']
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            hint: const Text('Select LAN Mode'),
          ),
          if (_mode == 'Manual') ...[
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Number of LANs',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _numLans = int.tryParse(value) ?? 1;
              },
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _processInput,
            child: const Text('Calculate'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}