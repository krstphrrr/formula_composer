import 'package:sqflite/sqflite.dart';

class IngredientEditRepository {
  final Database db;  // Inject SQLite database instance

  IngredientEditRepository(this.db);

}