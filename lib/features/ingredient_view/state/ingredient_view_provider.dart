import 'package:flutter/material.dart';

import '../domain/ingredient_view_service.dart';

class IngredientViewProvider extends ChangeNotifier  {
  final IngredientViewService _service;
  IngredientViewProvider(this._service);

  Map<String, dynamic>? _ingredients = {};
  Map<String, dynamic>? get ingredients => _ingredients;

    Future<void> fetchIngredientDetails(int id) async {
    _ingredients = await _service.fetchIngredient(id);
    notifyListeners();
  }
}