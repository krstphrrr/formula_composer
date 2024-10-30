import '../data/ingredient_view_repository.dart';

class IngredientViewService {
  final IngredientViewRepository _repository;
IngredientViewService(this._repository);

Future<Map<String, dynamic>?> fetchIngredient(int id) async {
  return await _repository.fetchIngredient(id);
}
}

