import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';

class FormulaListRepository {
  final Database db;  // Inject SQLite database instance

  FormulaListRepository(this.db);

Future<List<Map<String, dynamic>>> fetchFormulas() async {
     // Fetch the shared database instance
    try {
      print("Fetching formulas from the database...");
      final data = await db.query('formulas');
      print("Fetched formulas: $data");
      return data;  // Return the raw data to the provider
    } catch (e) {
      print("Error fetching formulas: $e");
      return [];  // Return an empty list in case of error
    }
  }
}