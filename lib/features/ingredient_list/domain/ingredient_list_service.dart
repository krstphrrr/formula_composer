import '../data/ingredient_list_repository.dart';

class IngredientListService {
  // static const platform = MethodChannel('com.example.formula/file_operations');

  final IngredientListRepository _repository;

  IngredientListService(this._repository);

  Future<List<Map<String, dynamic>>> fetchIngredients() async {
    return await _repository.fetchAllIngredients();
  }

  Future<void> deleteIngredient(int id) async {
    try {
      await _repository.deleteIngredient(id);
    } catch (e) {
      // if (kDebugMode) {
      print("ingredient_service: Error deleting ingredients: $e");
      // }
    }
  }
}
