import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';

class FormulaIngredientRepository {
  final Database db;  // Inject SQLite database instance

  FormulaIngredientRepository(this.db);

  Future<List<Map<String, dynamic>>> fetchAvailableIngredients() async {
  final db = await DatabaseHelper().database;
    print("Fetching ingredients from the database...");
    try {
      final data = await db.query('ingredients');
      print("Fetched ingredients: $data");
      // _ingredients = data;
      // notifyListeners();
      return data; // Return the fetched ingredients
    } catch (e) {
      print("Error fetching ingredients: $e");
      return []; // Return an empty list if there's an error
    }
  }


  Future<List<Map<String, dynamic>>> fetchIngredientsForFormula(int formulaId) async {
    final db = await DatabaseHelper().database;
    print("fetching formula ${formulaId}...");
    try {
      return await db.query(
        'formula_ingredients',
        where: 'formula_id = ?',
        whereArgs: [formulaId],
      );
    } catch (e) {
      print("Error fetching ingredients for formula $formulaId: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchIngredientById(int ingredientId) async {
    final db = await DatabaseHelper().database;
    try {
      final result = await db.query(
        'ingredients',
        where: 'id = ?',
        whereArgs: [ingredientId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print("Error fetching ingredient with id $ingredientId: $e");
      return null;
    }
  }

  Future<void> updateIngredientInFormula(Map<String, dynamic> ingredient) async {
    final db = await DatabaseHelper().database;
    try {
      await db.update(
        'formula_ingredients',
        {
          'amount': ingredient['amount'],
          'dilution': ingredient['dilution'],
        },
        where: 'id = ?',
        whereArgs: [ingredient['id']],
      );
    } catch (e) {
      print("Error updating ingredient in formula: $e");
    }
  }

  Future<void> deleteFormulaIngredient(int formulaId, int ingredientId) async {
     final db = await DatabaseHelper().database;
    try {
      await db.delete(
        'formula_ingredients',
        where: 'formula_id = ? AND ingredient_id = ?',
        whereArgs: [formulaId, ingredientId],
      );
      // if (kDebugMode) {
        print("Formula ingredient deleted successfully.");
      // }
    } catch (e) {
      // if (kDebugMode) {
        print("Error deleting formula ingredient: $e");
      // }
    }
  }

  Future<void> saveFormulaIngredients(int formulaId, List<Map<String, dynamic>> ingredients) async {
  final db = await DatabaseHelper().database;

  for (var ingredient in ingredients) {
    await db.insert('formula_ingredients', {
      'formula_id': formulaId,
      'ingredient_id': ingredient['ingredient_id'],
      'amount': ingredient['amount'],
      'dilution': ingredient['dilution'],
    });
  }
}

  Future<int?> saveFormulaToDatabase(Map<String, dynamic> formula) async {
    final db = await DatabaseHelper().database;
   print("Adding new formula with name: ${formula['name']}");
    try {
      int formulaId = await db.insert('formulas', {
        'name': formula['name'],
        'creation_date': formula['creation_date'],
        'notes': formula['notes'],
        'type': formula['type'],
      });

      return formulaId;
    } catch (e) {
      print("Error adding formula: $e");
       return null;
    }
  }

    Future<List<Map<String, dynamic>>> fetchFormulaIngredients(int formulaId) async {
    print("Fetching formula ingredients for formula ID $formulaId from the database...");
    try {
      // Query to join `formula_ingredients` with `ingredients` table based on the ingredient_id
      final data = await db.rawQuery('''
        SELECT fi.ingredient_id, fi.amount, fi.dilution, i.name
        FROM formula_ingredients fi
        INNER JOIN ingredients i ON fi.ingredient_id = i.id
        WHERE fi.formula_id = ?
      ''', [formulaId]);
      // final data = await db.rawQuery("SELECT * FROM formula_ingredients");
      print("Fetched formula ingredients: $data");
      return data;
    } catch (e) {
      print("Error fetching formula ingredients: $e");
      return [];
    }
  }

  // Add a new ingredient to a formula
  Future<void> addFormulaIngredient(int formulaId, int ingredientId, double amount, double dilution) async {
    final db = await DatabaseHelper().database;
    try {
      await db.insert('formula_ingredients', {
        'formula_id': formulaId,
        'ingredient_id': ingredientId,
        'amount': amount,
        'dilution': dilution
      });
      print("Formula ingredient added successfully.");
    } catch (e) {
      print("Error adding formula ingredient: $e");
    }
  }

  Future<void> updateIngredient(int ingredientId, double amount, double dilution) async {
    final db = await DatabaseHelper().database;
     print("updating ${ingredientId} with ${amount} and ${dilution} dil");
    await db.update(
      'formula_ingredients',
      {
        'amount': amount,
        'dilution': dilution,
      },
      where: 'id = ?',
      whereArgs: [ingredientId],
    );
  }

  Future<void> updateAllIngredients(int formulaId, List<Map<String, dynamic>> ingredients) async {
    final db = await DatabaseHelper().database;

    // Use a batch to perform all updates in a single transaction
    Batch batch = db.batch();
     print("updating all. ${ingredients} and id: ${formulaId}");

    for (var ingredient in ingredients) {
      batch.update(
        'formula_ingredients',
        {
          'amount': ingredient['amount'],
          'dilution': ingredient['dilution'],
        },
        where: 'formula_id = ? AND ingredient_id = ?',
        whereArgs: [formulaId, ingredient['ingredient_id']],
      );
    }

    await batch.commit(noResult: true);
  }
}