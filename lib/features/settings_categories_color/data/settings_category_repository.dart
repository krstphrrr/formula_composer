import 'package:sqflite/sqflite.dart';

class SettingsCategoryRepository {
final Database db;  // Inject SQLite database instance

  SettingsCategoryRepository(this.db);

  Future<List<Map<String, dynamic>>> loadCategories() async {
    return await db.query('olfactive_categories');
  }

  Future<void> updateCategoryColor(String category, String colorHex) async {
    await db.update(
      'olfactive_categories',
      {'color': colorHex},
      where: 'name = ?',
      whereArgs: [category],
    );
    print(await db.query("olfactive_categories"));
  }

  Future<void> addNewCategory(String category) async {
    await db.insert('olfactive_categories', {'name': category, 'color': null});
  }
}