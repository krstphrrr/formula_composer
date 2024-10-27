import 'dart:ui';

import '../data/settings_category_repository.dart';

class SettingsCategoryService {
final SettingsCategoryRepository _repository;

SettingsCategoryService(this._repository);

Future<List<Map<String, dynamic>>> fetchCategories() async {
    return await _repository.loadCategories();
  }

  Future<void> updateCategoryColor(String category, Color color) async {
    final colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    await _repository.updateCategoryColor(category, colorHex);
  }

  Future<void> addCategory(String category) async {
    await _repository.addNewCategory(category);
  }
}