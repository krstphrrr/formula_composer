import 'package:flutter/material.dart';
import '../domain/ingredient_list_service.dart';

class IngredientListProvider extends ChangeNotifier {

  // properties
  final IngredientListService _service;
  IngredientListProvider(this._service);

  List<Map<String, dynamic>> _filteredIngredients = [];
  List<Map<String, dynamic>> get filteredIngredients => _filteredIngredients;

  List<Map<String, dynamic>> _allIngredients = [];
  List<Map<String, dynamic>> get allIngredients => _allIngredients;

  Map<String, dynamic>? _singleIngredientDetails = {};
  Map<String, dynamic>? get singleIngredientDetails => _singleIngredientDetails;


  bool _isLoading = false;
  bool _hasError = false;
  bool isReverseSortEnabled = false;

  bool isExporting = false;
  bool isImporting = false;
  String? csvPath;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  String? lastSortOption;

  // methods
  void fetchAllIngredients() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      // _casController.clear();
      _allIngredients = await _service.fetchIngredients();
      _filteredIngredients = _allIngredients;
    } catch (e) {
      _hasError = true;
      // if (kDebugMode) {
        print("Error loading ingredients: $e");
      // }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}