import '../data/ingredient_edit_repository.dart';

class IngredientEditService {
  // INGREDIENT LIST PAGE PROPERTIES
  final IngredientEditRepository _repository;

  IngredientEditService(this._repository);

  Future<Map<String, dynamic>?> fetchIngredient(int id) async {
    return await _repository.fetchIngredient(id);
  }

  Future<List<Map<String, dynamic>>?> fetchCASNumbers(int id) async {
    final test = await _repository.fetchCASNumbers(id);
    print("TEST: $test");
    return test;
  }

  Future<void> addIngredient(
      Map<String, dynamic> ingredientDetails, List<String> casNumbers) async {
    print("services: $ingredientDetails");
    _repository.addIngredient(ingredientDetails, casNumbers);
  }

  Future<void> updateIngredient(
      Map<String, dynamic> ingredient, List<String> casNumbers) async {
    print("id pls: $ingredient");
    final int? id = ingredient['id'];

    if (id == null) {
      throw Exception('Ingredient ID is required');
    }
    final sanitizedData = ingredient.map((key, value) {
      // Replace null values with default values based on type
      if (value == null) {
        if (key == 'inventory_amount' ||
            key == 'cost_per_gram' ||
            // key == 'molecular_weight' ||
            key == 'substantivity') {
          return MapEntry(key, 0.0); // Default for numeric fields
        } else {
          return MapEntry(key, ''); // Default for string fields
        }
      }
      return MapEntry(key, value);
    });
    await _repository.updateIngredient(sanitizedData, casNumbers);
  }

  Future<void> deleteCASNumber(int id, String casNumber) async {
    _repository.deleteCASNumber(id, casNumber);
  }

  Future<void> addCASNumber(int id, String casNumber) async {
    print("from service: $id, $casNumber");
    _repository.addCASNumber(id, casNumber);
  }

  Future<List<String>> fetchCategories() async {
    return await _repository.fetchCategories();
  }
}
