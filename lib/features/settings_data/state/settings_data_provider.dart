import 'package:flutter/material.dart';

import '../domain/settings_data_service.dart';

class SettingsDataProvider extends ChangeNotifier {


  String? _csvFilePath;
  String get csvFileName => _csvFilePath != null ? _csvFilePath!.split('/').last : '';

  final SettingsDataService _service;

  SettingsDataProvider(this._service);

  Future<void> importData(BuildContext context) async {
    // var isImporting = true;
    notifyListeners();
    try {
      final result = await _service.pickCSVLocation();
      if (result != null) {
        String filePath = result.files.single.path!;
        await _service.importFromCSV(filePath);
        // Check if the widget is still mounted before showing the Snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data imported successfully!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to import csv: $e')));
      }
    } finally {
      // isImporting = false;
      notifyListeners();
    }
  }

  Future<void> truncateTable() async {
    await _service.truncateTable();
    notifyListeners();
  }

  Future<void> ingestCsv() async {
    if (_csvFilePath != null) {
      var data = await _service.processCsv(_csvFilePath!);
      // print()
      notifyListeners();
    }
  }
  
}