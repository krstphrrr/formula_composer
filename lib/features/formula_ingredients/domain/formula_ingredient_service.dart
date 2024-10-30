import 'package:formula_composer/features/formula_ingredients/data/formula_ingredient_repository.dart';

class FormulaIngredientService {
  final FormulaIngredientRepository _repository;
  FormulaIngredientService(this._repository);

  Future<List<Map<String, dynamic>>> getAvailableIngredients() async {
    return await _repository.fetchAvailableIngredients();
  }

  Future<List<Map<String, dynamic>>> getIngredientsForFormula(int formulaId) async {
    return await _repository.fetchIngredientsForFormula(formulaId);
  }

  Future<Map<String, dynamic>?> getIngredientById(int ingredientId) async {
    return await _repository.fetchIngredientById(ingredientId);
  }

  Future<void> updateIngredientInFormula(int ingredientId, double amount, double dilution) async {
    await _repository.updateIngredient(ingredientId, amount, dilution);
  }

  Future<void> removeIngredientFromFormula(int ingredientId) async {
    await _repository.removeIngredientFromFormula(ingredientId);
  }

  Future<void> saveFormulaIngredients(Map<String, dynamic> ingredients) async {
    //
  }

   Future<List<Map<String, dynamic>>> fetchFormulaIngredients(int formulaId) async {
    return await _repository.fetchFormulaIngredients(formulaId);
  }
    Future<void> addFormulaIngredient(int formulaId, int ingredientId, double amount, double dilution) async {
    await _repository.addFormulaIngredient(formulaId, ingredientId, amount, dilution);
  }

  Future<void> saveAllIngredients(int formulaId, List<Map<String, dynamic>> ingredients) async {
    await _repository.updateAllIngredients(formulaId, ingredients);
  }

}