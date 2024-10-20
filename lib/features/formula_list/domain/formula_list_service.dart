import '../data/formula_list_repositiory.dart';

class FormulaListService {
  // FormulaListService() : super();
   final FormulaListRepository _repository;

  FormulaListService(this._repository);

  Future<List<Map<String, dynamic>>> fetchFormulas() async {
    return await _repository.fetchFormulas();
  }
}