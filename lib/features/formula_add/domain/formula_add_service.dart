import '../data/formula_add_repository.dart';

class FormulaAddService {
  final FormulaAddRepository _repository;

  FormulaAddService(this._repository);

  Future<Map<String, dynamic>?> fetchFormula(int formulaId) async{
    return await _repository.fetchFormula(formulaId);
  }

  Future<void> addFormula(Map<String, dynamic> formula) async {
    await _repository.addFormula(formula);
  }

  Future<List<Map<String, dynamic>>> loadCategories() async{
    return await _repository.loadCategories();
  }
  
}