import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';

class IngredientListRepository {
  final Database db;  // Inject SQLite database instance

  IngredientListRepository(this.db);

  Future<List<Map<String, dynamic>>> fetchAllIngredients() async {
    final db = await DatabaseHelper().database;  // Fetch the shared database instance

    if (kDebugMode) {
      print("Fetching ingredients from the database...");
    }
    try {
      var ingredientsData = await db.query('ingredients');
      if (kDebugMode) {
        print("Fetched ingredients: $ingredientsData");
      }

      // For each ingredient, also fetch the related CAS numbers
      List<Map<String, dynamic>> updatedIngredients = [];

      for (var ingredient in ingredientsData) {
        // Make a mutable copy of the ingredient map
        var ingredientCopy = Map<String, dynamic>.from(ingredient);

        var ingredientId = ingredient['id'];
        var casNumbersData = await db.query('cas_numbers',
            where: 'ingredient_id = ?', whereArgs: [ingredientId]);

        // Extract CAS numbers and add them to the ingredient map
        List<String> casNumbers =
            casNumbersData.map((cas) => cas['cas'].toString()).toList();
        ingredientCopy['cas'] = casNumbers;

        updatedIngredients.add(ingredientCopy);
      }

    if (kDebugMode) {
      print("Fetched updated ingredients: $updatedIngredients");
    }
    return updatedIngredients; // Update the provider's ingredients list

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching ingredients: $e");
      }
      return [];
    }
  }
    Future<void> deleteIngredient(int id) async {
    final db = await DatabaseHelper().database;
    if (kDebugMode) {
      print("ingredient_repository: Deleting ingredient with id: $id");
    }
    try {
      await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
      if (kDebugMode) {
        print("Ingredient deleted successfully.");
      }

    } catch (e) {
      if (kDebugMode) {
        print("Error deleting ingredient: $e");
      }
    }
  }
  


}