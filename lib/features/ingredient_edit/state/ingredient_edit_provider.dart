import 'package:flutter/material.dart';

import '../domain/ingredient_edit_service.dart';

class IngredientEditProvider extends ChangeNotifier {
  // INGREDIENT LIST PAGE PROPERTIES
  final IngredientEditService _service;

  IngredientEditProvider(this._service);
}
