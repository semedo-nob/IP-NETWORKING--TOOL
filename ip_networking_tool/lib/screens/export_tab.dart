import 'package:flutter/material.dart';
import '../utils/export_to_csv.dart';
import '../utils/history_storage.dart';

class ExportTab extends StatelessWidget {
  const ExportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HistoryStorage.getHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data to export.'));
        }

        return Center(
          child: ElevatedButton(
            onPressed: () async {
              final latest = snapshot.data!.last;
              await exportToCsv(latest);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exported to CSV')),
              );
            },
            child: const Text('Export Latest Results as CSV'),
          ),
        );
      },
    );
  }
}