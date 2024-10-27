import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';

class IngredientEditRepository {
  final Database db; // Inject SQLite database instance

  IngredientEditRepository(this.db);

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

  Future<List<Map<String, dynamic>>?> fetchCASNumbers(int id) async {
    final db = await DatabaseHelper().database;
    print("Fetching CAS number with id: $id");
    try {
      final data = await db
          .query('cas_numbers', where: 'ingredient_id = ?', whereArgs: [id]);
      // if (data.isNotEmpty) {
      print("Fetched CAS numbers: $data");
      return data;
      // }
    } catch (e) {
      print("Error fetching CAS number: $e");
    }
    return null;
  }

  Future<void> addIngredient(
      Map<String, dynamic> ingredientDetails, List<String> casNumbers) async {
    final db = await DatabaseHelper().database;
    print("Adding new ingredient with name: $ingredientDetails['name']");
    try {
      // Insert the ingredient into the ingredients table
      final ingredientId = await db.insert('ingredients', {
        'name': ingredientDetails['name'],
        'category': ingredientDetails['category'],
        'inventory_amount': ingredientDetails['inventory_amount'],
        'cost_per_gram': ingredientDetails['cost_per_gram'],
        'supplier': ingredientDetails['supplier'],
        'acquisition_date': ingredientDetails['acquisition_date'],
        'description': ingredientDetails['description'],
        'personal_notes': ingredientDetails['personal_notes'],
        'supplier_notes': ingredientDetails['supplier_otes'],
        // 'molecular_weight': ingredientDetails['molecular_weight'],
        'pyramid_place': ingredientDetails['pyramid_place'],
        'substantivity': ingredientDetails['substantivity']
      });

      print("Ingredient added with ID: $ingredientId");
      // Update or add the CAS numbers
      // final casNumbers = ingredientDetails['casNumbers'];
      if (casNumbers.isNotEmpty) {
        // Delete existing CAS numbers for this ingredient (if necessary)
        // await db.delete('cas_numbers', where: 'ingredient_id = ?', whereArgs: [ingredientId]);

        // Add the new CAS numbers
        for (String cas in casNumbers) {
          await addCASNumber(ingredientId, cas);
        }
      }

      // Insert the CAS numbers into the cas_numbers table
      //  List<String> casNumbers = ingredientDetails['casNumbers'];
      // for (String cas in casNumbers) {
      //   await db.insert('cas_numbers', {
      //     'ingredient_id': ingredientId,
      //     'cas': cas,
      //   });
      //   if (kDebugMode) {
      //     print("CAS number $cas added for ingredient $ingredientId");
      //   }
      // }
    } catch (e) {
      // if (kDebugMode) {
      print("Error adding ingredient: $e");
      // }
    }
  }

  Future<void> addCASNumber(int ingredientId, String cas) async {
    final db = await DatabaseHelper().database;
    // if (kDebugMode) {
    print("Adding CAS number $cas for ingredient $ingredientId");
    // }
    try {
      await db.insert('cas_numbers', {
        'ingredient_id': ingredientId,
        'cas_number': cas,
      });
      // if (kDebugMode) {
      print("CAS number added successfully.");
      // }
    } catch (e) {
      // if (kDebugMode) {
      print("Error adding CAS number: $e");
      // }
    }
  }

  Future<void> updateIngredient(
      Map<String, dynamic> ingredient, List<String> casNumbers) async {
    final db = await DatabaseHelper().database;

    // Update the ingredient data
    await db.update(
      'ingredients',
      ingredient,
      where: 'id = ?',
      whereArgs: [ingredient['id']],
    );

    // Update or add the CAS numbers
    if (casNumbers.isNotEmpty) {
      // Delete existing CAS numbers for this ingredient (if necessary)
      await db.delete('cas_numbers',
          where: 'ingredient_id = ?', whereArgs: [ingredient['id']]);

      // Add the new CAS numbers
      for (String cas in casNumbers) {
        await addCASNumber(ingredient['id'], cas);
      }
    }
  }

  Future<void> deleteCASNumber(int id, String casNumber) async {
    final db = await DatabaseHelper().database;
    // if (kDebugMode) {
    print("Deleting CAS number with id: $id and cas_number: $casNumber");
    // }
    try {
      int result = await db.delete(
        'cas_numbers',
        where: 'id = ? AND cas_number = ?',
        whereArgs: [id, casNumber],
      );
      if (result > 0) {
        // if (kDebugMode) {
        print("CAS number deleted successfully.");
        // }
      } else {
        // if (kDebugMode) {
        print("No CAS number found to delete.");
        // }
      }
    } catch (e) {
      // if (kDebugMode) {
      print("Error deleting CAS number: $e");
      // }
    }
  }

  Future<List<String>> fetchCategories() async {
    final List<Map<String, dynamic>> result = await db.query(
      'olfactive_categories',
      columns: ['name'],
    );

    // Convert the result into a list of category names
    return result.map((row) => row['name'] as String).toList();
  }
}
// controllers: dispose and clear
// add ingredient / update ingredient
// cost calc
// substantivity calc
