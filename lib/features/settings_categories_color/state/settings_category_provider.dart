import 'package:flutter/material.dart';
import 'package:formula_composer/features/ingredient_list/presentation/ingredient_list_page.dart';
import 'package:formula_composer/features/ingredient_list/state/ingredient_list_provider.dart';
import 'package:provider/provider.dart';

import '../domain/settings_category_service.dart';

class SettingsCategoryProvider extends ChangeNotifier {

  final SettingsCategoryService _service;
  SettingsCategoryProvider(this._service);

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  
  Color? _selectedColor;
  Color? get selectedColor => _selectedColor;

  final TextEditingController _newCategoryController = TextEditingController();
  TextEditingController get newCategoryController => _newCategoryController;
  // Database? db;
   VoidCallback? onColorUpdated;

  void clearSelection() {
    _selectedCategory = null;
    _selectedColor = null;
    notifyListeners();
  }

  
  Future<void> loadCategories() async {
    _categories = await _service.fetchCategories();
    notifyListeners();
  }

void selectCategory(String category) {
  _selectedCategory = category;
  
  // Find the category's current color if it exists
  final selectedCategoryData = _categories.firstWhere(
    (cat) => cat['name'] == category,
    orElse: () => {},
  );

  if (selectedCategoryData['color'] != null) {
    // Parse color hex from database to Color object
    _selectedColor = Color(int.parse(selectedCategoryData['color'].replaceFirst('#', '0xFF')));
  } else {
    _selectedColor = null; // No color assigned
  }

  notifyListeners();
}

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Future<void> saveCategoryColor(BuildContext context) async {
    if (selectedCategory != null && selectedColor != null) {
      await _service.updateCategoryColor(selectedCategory!, selectedColor!);
      await loadCategories(); // Refresh the list after update

      // Notify IngredientListProvider of the new color
      final ingredientListProvider = Provider.of<IngredientListProvider>(context, listen: false);
      ingredientListProvider.updateCategoryColor(selectedCategory!, selectedColor!);
      
      clearSelection();
    }
  }

  Future<void> addCategory(String category) async {
    await _service.addCategory(category);
    await loadCategories(); // Refresh list after adding
  }

  
}