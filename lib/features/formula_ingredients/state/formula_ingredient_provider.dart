import 'package:flutter/material.dart';
import 'package:formula_composer/features/formula_ingredients/domain/formula_ingredient_service.dart';

class FormulaIngredientProvider extends ChangeNotifier {
  final FormulaIngredientService _service;
  FormulaIngredientProvider(this._service){
    // Initialize FocusNodes
    for (int i = 0; i < amountControllers.length; i++) {
      _amountFocusNodes.add(FocusNode());
      _dilutionFocusNodes.add(FocusNode());
      _amountFocusNodes[i].addListener(() {
        if (!_amountFocusNodes[i].hasFocus) {
          _saveIngredientChanges(i);
        }
      });
      _dilutionFocusNodes[i].addListener(() {
        if (!_dilutionFocusNodes[i].hasFocus) {
          _saveIngredientChanges(i);
        }
      });
    }
  }

  Map<String, dynamic>? _currentFormula;
  Map<String, dynamic>? get currentFormula => _currentFormula;
  
  int? _currentFormulaId = 1;
  int? get currentFormulaId => _currentFormulaId;

   List<Map<String, dynamic>> _availableIngredients = []; // List of all available ingredients
   List<Map<String, dynamic>> get availableIngredients => _availableIngredients; 

  List<Map<String, dynamic>> _filteredIngredients = []; // Filtered ingredients for the search
  List<Map<String, dynamic>> get filteredIngredients => _filteredIngredients;

  List<Map<String, dynamic>> _formulaIngredients = []; // Ingredients in the current formula
  List<Map<String, dynamic>> get formulaIngredients => _formulaIngredients;

  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  List<TextEditingController> _amountControllers = [];
  List<TextEditingController> get amountControllers => _amountControllers;

  List<TextEditingController> _dilutionControllers = [];
  List<TextEditingController> get dilutionControllers => _dilutionControllers;

  double _totalAmount = 0.0;
  double get totalAmount => _totalAmount;

  List<FocusNode> _amountFocusNodes = [];
  List<FocusNode> get amountFocusNodes =>  _amountFocusNodes;
  List<FocusNode> _dilutionFocusNodes = [];
  List<FocusNode> get dilutionFocusNodes => _dilutionFocusNodes;


   set currentFormulaId(int? value) {
    // if (_currentFormula!['formula_id'] != null) {
    _currentFormulaId = value;
    notifyListeners();
    // }
  }

    @override
  void dispose() {
    _searchController.dispose();
    for (var focusNode in _amountFocusNodes) {
      focusNode.dispose();
    }
    for (var focusNode in _dilutionFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

    void clearControllers() {
    _searchController.clear();
     notifyListeners();
  }


void initializeIngredients(int formulaId) async {
   // Clear old ingredients
    // _formulaIngredients = List.from([]);
    _amountControllers.clear();
    _dilutionControllers.clear();
    _amountFocusNodes.clear();
    _dilutionFocusNodes.clear();
    // Load formulaIngredients for the given formulaId
    // final ingredients = await _service.getIngredientsForFormula(formulaId);
    final ingredients = await _service.fetchFormulaIngredients(formulaId);
    print(ingredients);
    _formulaIngredients = List.from(ingredients);
    _availableIngredients = await _service.getAvailableIngredients();

    // Initialize controllers and focus nodes
    for (var ingredient in _formulaIngredients) {
      _amountControllers.add(TextEditingController(text: ingredient['amount'].toString()));
      _dilutionControllers.add(TextEditingController(text: ingredient['dilution'].toString()));
      
      // Create FocusNodes and add listeners
      FocusNode amountFocusNode = FocusNode();
      FocusNode dilutionFocusNode = FocusNode();

      // Adding listener to amount focus node
      amountFocusNode.addListener(() {
        if (!amountFocusNode.hasFocus) {
          // Save changes when focus is lost
          _service.updateIngredientInFormula(ingredient['id'], ingredient['amount'], ingredient['dilution']);
        }
      });

      // Adding listener to dilution focus node
      dilutionFocusNode.addListener(() {
        if (!dilutionFocusNode.hasFocus) {
          // Save changes when focus is lost
          _service.updateIngredientInFormula(ingredient['id'], ingredient['amount'], ingredient['dilution']);
        }
      });

      _amountFocusNodes.add(amountFocusNode);
      _dilutionFocusNodes.add(dilutionFocusNode);
    }

    notifyListeners();
  }

  void filterAvailableIngredients(String query) {
    if (query.isEmpty) {
      _filteredIngredients = List.from(_availableIngredients);
    } else {
      _filteredIngredients = _availableIngredients
          .where((ingredient) =>
              ingredient['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

Future<void> addIngredientToFormula(int ingredientId) async {
  final ingredient = await _service.getIngredientById(ingredientId);
  if (ingredient != null) {
    _formulaIngredients = List.from(_formulaIngredients);
    _formulaIngredients.add({
      'id': ingredient['id'],
      'name': ingredient['name'],
      'amount': 0.0,
      'dilution': 1.0,
    });

    // Add corresponding controllers for the new ingredient
    _amountControllers.add(TextEditingController(text: '0.0'));
    _dilutionControllers.add(TextEditingController(text: '1.0'));

    // Create and add focus nodes for the amount and dilution inputs
    FocusNode amountFocusNode = FocusNode();
    FocusNode dilutionFocusNode = FocusNode();

    amountFocusNode.addListener(() {
      if (!amountFocusNode.hasFocus) {
        final amount = double.tryParse(_amountControllers.last.text);
        final dilution = double.tryParse(_dilutionControllers.last.text);
        // Save changes when focus is lost
        _service.updateIngredientInFormula(ingredient['id'], amount!,  dilution!);
      }
    });

    dilutionFocusNode.addListener(() {
      if (!dilutionFocusNode.hasFocus) {
        final amount = double.tryParse(_amountControllers.last.text);
        final dilution = double.tryParse(_dilutionControllers.last.text);
        // Save changes when focus is lost
        _service.updateIngredientInFormula(ingredient['id'], amount!, dilution!);
      }
    });

    _amountFocusNodes.add(amountFocusNode);
    _dilutionFocusNodes.add(dilutionFocusNode);

    notifyListeners();
  }
}

  void removeIngredient(int index) async {
    int ingredientId = _formulaIngredients[index]['id'];
    await _service.removeIngredientFromFormula(ingredientId);
    
    _formulaIngredients.removeAt(index);
    _amountControllers.removeAt(index);
    _dilutionControllers.removeAt(index);
    _amountFocusNodes.removeAt(index).dispose();  // Dispose of the FocusNode properly
    _dilutionFocusNodes.removeAt(index).dispose();  // Dispose of the FocusNode properly

    notifyListeners();
  }

  // void updateIngredientInFormula(int index, double amount, double dilution) async {
  //   _formulaIngredients[index]['amount'] = amount;
  //   _formulaIngredients[index]['dilution'] = dilution;

  //   await _service.updateIngredientInFormula(_formulaIngredients[index]);

  //   calculateTotalAmount();
  //   notifyListeners();
  // }

  void calculateTotalAmount() {
    _totalAmount = _formulaIngredients.fold(0.0, (sum, ingredient) {
      return sum + (ingredient['amount'] * ingredient['dilution']);
    });
  }

  // Add a new formula ingredient
  Future<void> addFormulaIngredient(
      int formulaId, int ingredientId, double amount, double dilution) async {
    await _service.addFormulaIngredient(
        formulaId, ingredientId, amount, dilution);
              print("CURRENT FORMULA: $_currentFormula");
    fetchFormulaIngredients(formulaId); // Refresh the list after adding
  }

void fetchFormulaIngredients(int formulaId) async{
   _formulaIngredients =
        await _service.fetchFormulaIngredients(formulaId);
       calculateTotalAmount();
    notifyListeners();
}


  void saveIngredients(BuildContext context) async {
    
    // Show success message or handle errors if necessary
  }

   Future<void> _saveIngredientChanges(int index) async {
    double amount = double.tryParse(_amountControllers[index].text) ?? 0.0;
    double dilution = double.tryParse(dilutionControllers[index].text) ?? 1.0;
    final ingredient = formulaIngredients[index];
    
    // Update in database
    await _service.updateIngredientInFormula(ingredient['id'], amount, dilution);
    
    // Notify listeners (optional, depending on UI changes)
    notifyListeners();
  }

   Future<void> saveAllChanges(int formulaId) async {
    List<Map<String, dynamic>> updatedIngredients = [];

    for (int i = 0; i < _formulaIngredients.length; i++) {
      double amount = double.tryParse(_amountControllers[i].text) ?? 0.0;
      double dilution = double.tryParse(_dilutionControllers[i].text) ?? 1.0;

      updatedIngredients.add({
        'ingredient_id': _formulaIngredients[i]['ingredient_id'],
        'amount': amount,
        'dilution': dilution,
      });
    }

    await _service.saveAllIngredients(formulaId, updatedIngredients);
  }
}
// Previously, I added a new list item and searched for an ingredient inside the dropdown within the added list item. Now that the search bar determines what gets added