import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';

class SettingsDataRepository {
  final Database db; 

  SettingsDataRepository(this.db);

    Future<void> truncateTable() async {
    final db = await DatabaseHelper().database;  // Fetch the shared database instance
    await db.execute('DELETE FROM ifra_standards');
  }

  Future<void> insertIfraStandardIntoDatabase(Map<String, dynamic> ifraStandard) async {
    final db = await DatabaseHelper().database;
    try {
      await db.insert('ifra_standards', ifraStandard);
        print("Inserted IFRA standard: $ifraStandard");
    } catch (e) {
        print("Failed to insert IFRA standard: $e");
    }
  }
}