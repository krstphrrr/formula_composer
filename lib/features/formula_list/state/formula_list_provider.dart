import 'package:flutter/material.dart';

import '../domain/formula_list_service.dart';

class FormulaListProvider extends ChangeNotifier {
  final FormulaListService _service;
  FormulaListProvider(this._service);

  // properties
   
  List<Map<String, dynamic>> _formulas = [];
  List<Map<String, dynamic>> get formulas => _formulas;
  bool get isLoading => _isLoading;
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;
  

  // methods
   // Fetch all formulas
  Future<void> fetchFormulas() async {
    _isLoading = true;
    notifyListeners();  // Notify UI that loading started

    _formulas = await _service.fetchFormulas();
    _isLoading = false;
    notifyListeners();  // Notify UI that loading is complete
  }

}