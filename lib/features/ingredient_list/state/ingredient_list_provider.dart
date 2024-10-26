import 'package:flutter/material.dart';
import '../domain/ingredient_list_service.dart';

class IngredientListProvider extends ChangeNotifier {
  // properties
  final IngredientListService _service;
  IngredientListProvider(this._service);

  List<Map<String, dynamic>> _filteredIngredients = [];
  List<Map<String, dynamic>> get filteredIngredients => _filteredIngredients;

  List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> get ingredients => _ingredients;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void clearControllers() {
    // _selectedIngredient = null;
    _searchController.clear();
    notifyListeners(); // Ensure UI gets updated
  }

  set ingredients(List<Map<String, dynamic>> value) {
    _ingredients = value;
    notifyListeners();
  }

  // methods
  void fetchIngredients() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      // _casController.clear();
      _ingredients = await _service.fetchIngredients();
      _filteredIngredients = _ingredients;
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

  Future<void> deleteIngredient(int ingredientId) async {
    _isLoading = true;
    _hasError = false;
    try {
      await _service.deleteIngredient(ingredientId);
      clearControllers();
    } catch (e) {
      _hasError = true;
      // if (kDebugMode) {
      print("Error deleting ingredient: $e");
      // }
    } finally {
      _isLoading = false;
      notifyListeners();
      fetchIngredients();
    }
  }

  // filter ingredients logic
  //  sort logic
  // delete ingredient
  // total number in inv
  // total cost

  // ingredient list item appearance: editable colors? pyramid logic? subtitles?
  // for color chooser: custom widget
  // export and import logic
}
