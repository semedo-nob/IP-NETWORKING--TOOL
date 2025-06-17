import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryStorage {
  static Future<String> _getHistoryFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/history.json';
  }

  static Future<void> saveHistory(Map<String, dynamic> entry) async {
    final filePath = await _getHistoryFilePath();
    final file = File(filePath);
    List<Map<String, dynamic>> history = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      history = List<Map<String, dynamic>>.from(jsonDecode(content));
    }

    history.add(entry);
    await file.writeAsString(jsonEncode(history));
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final filePath = await _getHistoryFilePath();
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(jsonDecode(content));
    }
    return [];
  }
}