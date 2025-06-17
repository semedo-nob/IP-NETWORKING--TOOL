import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> exportToCsv(Map<String, dynamic> data) async {
  final List<List<dynamic>> csvData = [
    ['Input', data['input']],
    ['Operation', data['operation']],
    ['Mode', data['mode']],
    ['Network', data['network']],
    if (data['bitwiseResult'] != null) ...[
      ['Bitwise Binary', data['bitwiseResult']['binary']],
      ['Bitwise IP', data['bitwiseResult']['ip']],
    ],
    ['Subnets'],
    ['LAN', 'Network Address', 'Broadcast Address', 'Usable IPs', 'CIDR', 'Subnet Mask'],
    ...(data['subnets'] as List<Map<String, dynamic>>).asMap().entries.map((entry) {
      final i = entry.key + 1;
      final subnet = entry.value;
      return [
        'LAN $i',
        subnet['network_address'],
        subnet['broadcast_address'],
        subnet['usable_ips'],
        '/${subnet['prefixlen']}',
        subnet['netmask'],
      ];
    }),
  ];

  final csv = const ListToCsvConverter().convert(csvData);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/ip_networking_results.csv';
  final file = File(path);
  await file.writeAsString(csv);
}