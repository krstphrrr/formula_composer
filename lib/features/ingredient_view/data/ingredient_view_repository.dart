import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';

class IngredientViewRepository {
  final Database db; // Inject SQLite database instance

  IngredientViewRepository(this.db);

  Future<Map<String, dynamic>?> fetchIngredient(int id) async {
    final db = await DatabaseHelper().database;
    // if (kDebugMode) {
    print("Fetching ingredient with id: $id");
    // }
    try {
      final data =
          await db.query('ingredients', where: 'id = ?', whereArgs: [id]);
      if (data.isNotEmpty) {
        // if (kDebugMode) {
        print("Fetched ingredient: ${data.first}");
        // }
        return data.first;
      }
    } catch (e) {
      // if (kDebugMode) {
      print("Error fetching ingredient: $e");
      // }
    }
    return null;
  }
}