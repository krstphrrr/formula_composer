import 'package:flutter/material.dart';
import 'package:formula_composer/features/formula_ingredients/domain/formula_ingredient_service.dart';

class FormulaIngredientProvider extends ChangeNotifier {
  final FormulaIngredientService _service;
  FormulaIngredientProvider(this._service){
  
  }

  Map<String, dynamic>? _currentFormula;
  Map<String, dynamic>? get currentFormula => _currentFormula;

   String _formulaDisplayName = '';
  String get formulaDisplayName => _formulaDisplayName;
  
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
    set formulaDisplayName(String? value){
    _formulaDisplayName = value!;
    notifyListeners();
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

    // Dispose of controllers
    for (var controller in _amountControllers) {
      controller.dispose();
    }
    for (var controller in _dilutionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

    void clearControllers() {
    _searchController.clear();
     notifyListeners();
  }

void _initializeFocusNodes(int index) {
  FocusNode amountFocusNode = FocusNode();
  FocusNode dilutionFocusNode = FocusNode();

  amountFocusNode.addListener(() {
    if (!amountFocusNode.hasFocus) {
      double amount = double.tryParse(_amountControllers[index].text) ?? 0.0;
      updateIngredientInFormula(
        index,
        _formulaIngredients[index]['ingredient_id'],
        amount,
        _formulaIngredients[index]['dilution'],
      );
      print("CHANGED AMOUNT");
    }
  });

  dilutionFocusNode.addListener(() {
    if (!dilutionFocusNode.hasFocus) {
      double dilution = double.tryParse(_dilutionControllers[index].text) ?? 1.0;
      updateIngredientInFormula(
        index,
        _formulaIngredients[index]['ingredient_id'],
        _formulaIngredients[index]['amount'],
        dilution,
      );
      print("CHANGE DILUTION");
    }
  });

  _amountFocusNodes.add(amountFocusNode);
  _dilutionFocusNodes.add(dilutionFocusNode);
}

Future<void> fetchFormulaIngredients(int formulaId) async {
  var ingredients = await _service.fetchFormulaIngredients(formulaId);
  _formulaIngredients = ingredients.map((ingredient) => Map<String, dynamic>.from(ingredient)).toList();
  
  print("FORMULA ING ON PROVIDER: ${_formulaIngredients}");
  print("pretotal: ${_totalAmount}");
  
  _totalAmount = _service.calculateTotalAmount(_formulaIngredients);
  print("posttotal: ${_totalAmount}");
  
  _amountControllers = _formulaIngredients.map((ingredient) {
    return TextEditingController(text: ingredient['amount'].toString());
  }).toList();
  
  _dilutionControllers = _formulaIngredients.map((ingredient) {
    return TextEditingController(text: ingredient['dilution'].toString());
  }).toList();

  notifyListeners();
}


// void initializeIngredients() async {
//    // Clear old ingredients
//    _filteredIngredients = List.from(_availableIngredients);
//     // _formulaIngredients = List.from([]);
//     // _amountControllers.clear();
//     // _dilutionControllers.clear();
//     // _amountFocusNodes.clear();
//     // _dilutionFocusNodes.clear();
//     // Load formulaIngredients for the given formulaId
//     // final ingredients = await _service.getIngredientsForFormula(formulaId);
//     // final ingredients = await _service.fetchFormulaIngredients(formulaId);
//     // print("FORM INGREDIENTS : {$ingredients}");
//     // _formulaIngredients = List.from(ingredients);
//     // _availableIngredients = await _service.getAvailableIngredients();

//     // Initialize controllers and focus nodes
//     // for (var ingredient in _formulaIngredients) {
//     //   _amountControllers.add(TextEditingController(text: ingredient['amount'].toString()));
//     //   _dilutionControllers.add(TextEditingController(text: ingredient['dilution'].toString()));
      
//     //   // Create FocusNodes and add listeners
//     //   FocusNode amountFocusNode = FocusNode();
//     //   FocusNode dilutionFocusNode = FocusNode();

//     //   // Adding listener to amount focus node
//     //   amountFocusNode.addListener(() {
//     //     if (!amountFocusNode.hasFocus) {
//     //       // Save changes when focus is lost
//     //       _service.updateIngredientInFormula(ingredient['id'], ingredient['amount'], ingredient['dilution']);
//     //     }
//     //   });

//     //   // Adding listener to dilution focus node
//     //   dilutionFocusNode.addListener(() {
//     //     if (!dilutionFocusNode.hasFocus) {
//     //       // Save changes when focus is lost
//     //       _service.updateIngredientInFormula(ingredient['id'], ingredient['amount'], ingredient['dilution']);
//     //     }
//     //   });

//     //   _amountFocusNodes.add(amountFocusNode);
//     //   _dilutionFocusNodes.add(dilutionFocusNode);
//     // }

//     notifyListeners();
//   }
//    // Fetch available ingredients
  Future<void> fetchAvailableIngredients() async {
    _availableIngredients =
        List.from(await _service.fetchAvailableIngredients());
    _filteredIngredients = _availableIngredients;
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

Future<void> addIngredientToFormula(int rowIndex, int ingredientId) async {
  // add ingredient


  _formulaIngredients[rowIndex]['ingredient_id'] = ingredientId;

  _service.addFormulaIngredient(
    _currentFormulaId!, 
    ingredientId, 
    double.tryParse(_amountControllers[rowIndex].text) ?? 0.0, 
    double.tryParse(_dilutionControllers[rowIndex].text) ?? 1.0);
  // initializeFocusNodes(_formulaIngredients.length);
    // fetchFormulaIngredients(_currentFormulaId!);

  
  // final ingredient = await _service.getIngredientById(ingredientId);

  // if (ingredient != null) {
  //   _formulaIngredients = List.from(_formulaIngredients);
  //   _formulaIngredients.add({
  //     'id': ingredient['id'],
  //     'name': ingredient['name'],
  //     'amount': 0.0,
  //     'dilution': 1.0,
  //   });

  //   // Add corresponding controllers for the new ingredient
  //   _amountControllers.add(TextEditingController(text: '0.0'));
  //   _dilutionControllers.add(TextEditingController(text: '1.0'));

    // Create and add focus nodes for the amount and dilution inputs
    // FocusNode amountFocusNode = FocusNode();
    // FocusNode dilutionFocusNode = FocusNode();

    // amountFocusNode.addListener(() {
    //   if (!amountFocusNode.hasFocus) {
    //     final amount = double.tryParse(_amountControllers.last.text);
    //     final dilution = double.tryParse(_dilutionControllers.last.text);
    //     // Save changes when focus is lost
    //     _service.updateIngredientInFormula(ingredient['id'], amount!,  dilution!);
    //   }
    // });

    // dilutionFocusNode.addListener(() {
    //   if (!dilutionFocusNode.hasFocus) {
    //     final amount = double.tryParse(_amountControllers.last.text);
    //     final dilution = double.tryParse(_dilutionControllers.last.text);
    //     // Save changes when focus is lost
    //     _service.updateIngredientInFormula(ingredient['id'], amount!, dilution!);
    //   }
    // });

    // _amountFocusNodes.add(amountFocusNode);
    // _dilutionFocusNodes.add(dilutionFocusNode);
    // _initializeFocusNodes(rowIndex);

    notifyListeners();
    // await checkIfraCompliance(context);
  }

  void addIngredientRow(BuildContext context, int index) async {
    print(_availableIngredients);
    
    final List<Map<String, dynamic>> mutableIngredientList =
        List.from(_formulaIngredients);

    // Add a new ingredient with default values to the in-memory state
    mutableIngredientList.add({
      'ingredient_id': _availableIngredients[index]['id'], // No ingredient selected by default
      'amount': 0.0, // Default amount
      'dilution': 1.0, // Default dilution,
      'name':_availableIngredients[index]['name']
    });
    _formulaIngredients = mutableIngredientList;
    print("${_formulaIngredients}, ${_availableIngredients[index]}");

    // // Add new controllers
    _amountControllers.add(TextEditingController(text: '0.0'));
    _dilutionControllers.add(TextEditingController(text: '1.0'));
    // print("CREATED ROW: ${_formulaIngredients}");


// AKI
    // Ensure focus nodes are reinitialized to match the new ingredient count
    _initializeFocusNodes(index);
    // fetchFormulaIngredients(_currentFormulaId!);
    // fetchAvailableIngredients();

    notifyListeners();
    addIngredientToFormula(index, _availableIngredients[index]['id']);
    // await checkIfraCompliance(context);
  }

  void removeIngredient(int index) async {
    print("PRE REM: ${_formulaIngredients}");
    // int ingredientId = _formulaIngredients[index]['id'];
    // await _service.removeIngredientFromFormula(ingredientId);
    await _service.deleteFormulaIngredient(
        _currentFormulaId!, _formulaIngredients[index]['ingredient_id']);
    
    _formulaIngredients.removeAt(index);
    _amountControllers.removeAt(index);
    _dilutionControllers.removeAt(index);
    _amountFocusNodes.removeAt(index).dispose();  // Dispose of the FocusNode properly
    _dilutionFocusNodes.removeAt(index).dispose();  // Dispose of the FocusNode properly
     print("POST REM: ${_formulaIngredients}");
    //  final ingredient = _formulaIngredients[index];

     
    
    // notifyListeners();
    notifyListeners();
  }

    // Delete a formula ingredient
  Future<void> deleteFormulaIngredient(int formulaId, int ingredientId) async {
    await _service.deleteFormulaIngredient(
        formulaId, ingredientId);
    await fetchFormulaIngredients(formulaId); // Refresh the list after deleting
  }

  void updateIngredientInFormula(
    int index, 
    int ingredientId, 
    double amount, 
    double dilution) async {
      print("updating from provider: ${amount}");
    _formulaIngredients[index]['amount'] = amount;
    _formulaIngredients[index]['dilution'] = dilution;

    await _service.updateIngredientInFormula(_currentFormulaId!, ingredientId, amount, dilution);

    _totalAmount =
        _service.calculateTotalAmount(formulaIngredients);
    notifyListeners();
  }

 void calculateTotalAmount() {
    _totalAmount = _formulaIngredients.asMap().entries.fold(0.0, (sum, entry) {
      final index = entry.key;
      final ingredient = entry.value;
      final dilution = double.tryParse(_dilutionControllers[index].text) ?? 1.0;
      return sum +
          (ingredient['amount'] * dilution); // Amount * dilution factor
    });
    notifyListeners();
  }
  // Add a new formula ingredient
  // Future<void> addFormulaIngredient(
  //     int formulaId, int ingredientId, double amount, double dilution) async {
  //   await _service.addFormulaIngredient(
  //       formulaId, ingredientId, amount, dilution);
  //             print("CURRENT FORMULA: $_currentFormula");
  //   fetchFormulaIngredients(formulaId); // Refresh the list after adding
  // }



//   void saveIngredients(BuildContext context) async {
    
//     // Show success message or handle errors if necessary
//   }

//    Future<void> _saveIngredientChanges(int index) async {
//     double amount = double.tryParse(_amountControllers[index].text) ?? 0.0;
//     double dilution = double.tryParse(_dilutionControllers[index].text) ?? 1.0;
//     final ingredient = _formulaIngredients[index];
   
    
//     // Update in database
//     await _service.updateIngredientInFormula(ingredient['id'], amount, dilution);
    
//     // Notify listeners (optional, depending on UI changes)
//     notifyListeners();
//   }

//    Future<void> saveAllChanges(int formulaId) async {
//     List<Map<String, dynamic>> updatedIngredients = [];

//     for (int i = 0; i < _formulaIngredients.length; i++) {
//       double amount = double.tryParse(_amountControllers[i].text) ?? 0.0;
//       double dilution = double.tryParse(_dilutionControllers[i].text) ?? 1.0;

//       print("INGREDIENT ON SAVE: ${_formulaIngredients}");
//       updatedIngredients.add({
//         'ingredient_id': _formulaIngredients[i]['id'],
//         'amount': amount,
//         'dilution': dilution,
//       });
//     }

//     await _service.saveAllIngredients(formulaId, updatedIngredients);
//   }


void updateDilutionFactor(int index, String value) {
    final dilution = double.tryParse(value) ?? 1.0;
    _formulaIngredients[index]['dilution'] = dilution;
    calculateTotalAmount(); // Recalculate total when dilution changes
    notifyListeners();
  }

}
// Previously, I added a new list item and searched for an ingredient inside the dropdown within the added list item. Now that the search bar determines what gets added