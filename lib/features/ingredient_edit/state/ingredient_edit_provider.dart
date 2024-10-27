import 'package:flutter/material.dart';

import '../domain/ingredient_edit_service.dart';

class IngredientEditProvider extends ChangeNotifier {
  final IngredientEditService _service;
  IngredientEditProvider(this._service);

  int? _selectedIngredient = null;
  int? get selectedIngredient => _selectedIngredient;

  Map<String, dynamic> _selectedIngredientDetails = {};
  Map<String, dynamic> get selectedIngredientDetails => _selectedIngredientDetails;

  List<Map<String, dynamic>>? _fetchedCASNumbers = [];
  List<Map<String, dynamic>>? get fetchedCASNumbers => _fetchedCASNumbers;

  List<String> _casNumbers = [];
  List<String> get casNumbers => _casNumbers;

  TextEditingController _commonNameController = TextEditingController();
  TextEditingController get commonNameController => _commonNameController;

  TextEditingController _casController = TextEditingController();
  TextEditingController get casController => _casController;

  TextEditingController _inventoryAmountController = TextEditingController();
  TextEditingController get inventoryAmountController => _inventoryAmountController;

  TextEditingController _costController = TextEditingController();
  TextEditingController get costController => _costController;

  TextEditingController _supplierController = TextEditingController();
  TextEditingController get supplierController => _supplierController;

  TextEditingController _acquisitionDateController = TextEditingController();
  TextEditingController get acquisitionDateController => _acquisitionDateController;

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController get descriptionController => _descriptionController;

  TextEditingController _personalNotesController = TextEditingController();
  TextEditingController get personalNotesController => _personalNotesController;

  TextEditingController _supplierNotesController = TextEditingController();
  TextEditingController get supplierNotesController => _supplierNotesController;

  TextEditingController _molecularWeightController = TextEditingController();
  TextEditingController get molecularWeightController => _molecularWeightController;

  TextEditingController _substantivityController = TextEditingController();
  TextEditingController get substantivityController => _substantivityController;

  
  TextEditingController _hoursController = TextEditingController();
  TextEditingController get hoursController => _hoursController;

  
  TextEditingController _concentrationController = TextEditingController();
  TextEditingController get concentrationController => _concentrationController;

  TextEditingController _amountPaidController = TextEditingController();
  TextEditingController get amountPaidController => _amountPaidController;

   
  String _category = '';
  String get category => _category;

  List<String> _categories = [];
  List<String> get categories => _categories;

  TextEditingController _categoryController = TextEditingController();
  TextEditingController get categoryController => _categoryController;

  TextEditingController _pyramidPlaceController = TextEditingController();
    TextEditingController get pyramidPlaceController => _pyramidPlaceController;

  final double _conversionRate = 1.25; 
  List<Map<String, dynamic>> _allIngredients = [];
  List<Map<String, dynamic>> get allIngredients => _allIngredients;
  int get totalIngredients => _allIngredients.length;

  String _selectedCurrency = 'USD'; 
  String get selectedCurrency => _selectedCurrency;

    // Setter for selectedIngredient
  set selectedIngredient(int? value) {
    _selectedIngredient = value;
    notifyListeners();  // Notify listeners of the change
  }

    final Map<String, int> pyramidPlaceOrder = {
    'base': 1,
    'mid-base': 2,
    'mid': 3,
    'top-mid': 4,
    'top': 5,
  };

  @override
  void dispose() {
    _pyramidPlaceController.dispose();
    _commonNameController.dispose();
    _inventoryAmountController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    _acquisitionDateController.dispose();
    _descriptionController.dispose();
    _personalNotesController.dispose();
    _supplierNotesController.dispose();
    _molecularWeightController.dispose();
    _casController.dispose();
    _substantivityController.dispose();
    _categoryController.dispose();

    _hoursController.dispose();
    _concentrationController.dispose();
    _amountPaidController.dispose();
    _casNumbers = [];
    super.dispose();
  }

    void clearControllers() {
    // _selectedIngredient = null;
    _amountPaidController.clear();
    _categoryController.clear();
    _casNumbers = [];
    _fetchedCASNumbers = [];
    _selectedIngredientDetails = {};
    _commonNameController.clear();
    _casController.clear();
    _inventoryAmountController.clear();
    _costController.clear();
    _supplierController.clear();
    _acquisitionDateController.clear();
    _descriptionController.clear();
    _personalNotesController.clear();
    _supplierNotesController.clear();
    _molecularWeightController.clear();
    _substantivityController.clear();
    _pyramidPlaceController.clear();

    _hoursController.clear();
    _concentrationController.clear();
    notifyListeners();  // Ensure UI gets updated
  }

    void setCategory(String newCategory) {
    _category = newCategory;
    notifyListeners(); // This will update the UI after the change
  }

  void setPyramidPlace(String newPyramidPlace) {
    _pyramidPlaceController.text = newPyramidPlace;
    notifyListeners(); // Notify the listeners to update the UI
  }

  void updateAcquisitionDate(String newDate) {
  acquisitionDateController.text = newDate;
  notifyListeners();
}
  void loadIngredientDetails() async {
    clearControllers();
    print("_cas1: $_casNumbers");
    print("_fetched21: $_fetchedCASNumbers");
    print("_selected1: $_selectedIngredientDetails");
    if (_selectedIngredient != null) {
      // Fetch the ingredient details
      final fetchedIngredient =
      await _service.fetchIngredient(_selectedIngredient!);
      await fetchCASNumbers(_selectedIngredient!);

      
    

      if (fetchedIngredient != null) {
        _selectedIngredientDetails = fetchedIngredient;
        _commonNameController.text = _selectedIngredientDetails['name'] ?? '';
        _categoryController.text = _selectedIngredientDetails['category'];
        _inventoryAmountController.text = _selectedIngredientDetails['inventory_amount'].toString() ?? '0.0';
        _costController.text = _selectedIngredientDetails['cost_per_gram'].toString() ?? '0.0';
        _supplierController.text = _selectedIngredientDetails['supplier'] ?? '';
        _descriptionController.text = _selectedIngredientDetails['description'] ?? '';
        // _acquisitionDateController.text = _selectedIngredientDetails['acquisitionm']
        _personalNotesController.text = _selectedIngredientDetails['personal_notes'] ?? '';
        _supplierNotesController.text = _selectedIngredientDetails['supplier_notes'] ?? '';
        // _molecularWeightController.text = _selectedIngredientDetails['molecular_weight'].toString();
        _pyramidPlaceController.text = _selectedIngredientDetails['pyramid_place'] ?? '';
        _substantivityController.text = _selectedIngredientDetails['substantivity'].toString();

        // Parse acquisition date
        if (_selectedIngredientDetails['acquisition_date'] != null) {
          try {
            DateTime parsedDate = DateTime.parse(_selectedIngredientDetails[
                'acquisition_date']); // Parse the date from the database
            _acquisitionDateController.text = parsedDate
                .toIso8601String()
                .split('T')
                .first; // Format as YYYY-MM-DD
          } catch (e) {
            print('Error parsing acquisition date: $e');
          }
        } else {
          _acquisitionDateController.text = ''; // Clear if no date is provided
        }
      }
    }
    print("INGREDIENTS: $_selectedIngredientDetails");
    // print('COMMON NAME: $commonName');
    notifyListeners();

    print("CAS NUMBERS: $_fetchedCASNumbers");
    if (_fetchedCASNumbers != null) {
      _casNumbers = _fetchedCASNumbers!
          .map((casMap) => casMap['cas_number'] as String)
          .toList();
      // _selectedIngredientDetails['cas_number'] = _casNumbers;
      notifyListeners();
    }

    print("_cas: $_casNumbers");
    print("_fetched: $_fetchedCASNumbers");
    print("_selected: $_selectedIngredientDetails");
  }

  Future<void> fetchCASNumbers(int ingredientId) async {
  // Fetch the CAS numbers from the service
  final result = await _service.fetchCASNumbers(ingredientId);
  print("FETCHHHHH: $result");

  // Check if result is not null and assign it to _fetchedCASNumbers
  if (result != null) {
    _fetchedCASNumbers = result;
  } else {
    _fetchedCASNumbers = [];
  }

  // Notify listeners to update the UI or state
  notifyListeners();
}

void saveIngredient(Map<String, dynamic> ingredientData, List<String> casNumbers) async {
    
    if (_selectedIngredient == null) {
      // Call service to add new ingredient
      await _service.addIngredient(ingredientData, casNumbers);
    } else {
      // Call service to update existing ingredient
      await _service.updateIngredient(ingredientData, _casNumbers);
    }

    notifyListeners();
  }

  void updateIngredient(
      Map<String, dynamic> ingredient, List<String> casNumbers) async {
        ingredient['id'] = _selectedIngredient;
    await _service.updateIngredient(ingredient, casNumbers);
    clearControllers();
    notifyListeners();
  }

  void addIngredient(Map<String, dynamic> ingredientData, List<String> casNumbers) async {
  // Call the service and pass the ingredient data directly
  await _service.addIngredient({
    'name': ingredientData['name'],
    'category': ingredientData['category'],
    'inventory_amount': ingredientData['inventory_amount'],
    'cost_per_gram': ingredientData['cost_per_gram'],
    'supplier': ingredientData['supplier'],
    'acquisition_date': ingredientData['acquisition_date'],
    'description': ingredientData['description'],
    'personal_notes': ingredientData['personal_notes'],
    'supplier_notes': ingredientData['supplier_notes'],
    // 'molecular_weight': ingredientData['molecular_weight'],
    'pyramid_place': ingredientData['pyramid_place'],
    'substantivity': ingredientData['substantivity'],
    // 'cas_numbers': ingredientData['cas_numbers'],
  }, casNumbers);

  // Fetch updated ingredients and notify listeners
  clearControllers();
  notifyListeners();
}

  void removeCASNumber(String cas) async {
    _casNumbers.remove(cas);
    _casController.clear();

    if (_selectedIngredient != null) {
      await _service.deleteCASNumber(
          _selectedIngredient!, cas); // Persist CAS number deletion
      fetchCASNumbers(_selectedIngredient!);
    }

    notifyListeners();
  }

    void confirmCASNumber() async {

    String cas = _casController.text.trim();
    print("CAS PRessed: $cas, $casController ANFDD $selectedIngredient");
    if (cas.isNotEmpty) {
      _casNumbers.add(cas); // Add the confirmed CAS number to the list
      _casController.clear(); // Clear the input field for the next CAS number

      if (_selectedIngredient != null) {
        print("sel ing: $selectedIngredient");
        await _service.addCASNumber(
            _selectedIngredient!, cas); // Persist CAS number
        fetchCASNumbers(
            _selectedIngredient!); // Fetch only if _selectedIngredient is not null
      }
    }
    notifyListeners();
  }

  //   void fetchIngredient(int ingredientId) async {
  //   _singleIngredientDetails =
  //       await _ingredientService.fetchIngredient(ingredientId);
  //   notifyListeners();
  // }

  void updateCategory(String newCategory) {
    _categoryController.text = newCategory;
    notifyListeners(); // Rebuilds any listening widgets
  }

   // Method to update pyramidPlace and notify listeners
  void updatePyramidPlace(String newPyramidPlace) {
    _pyramidPlaceController.text = newPyramidPlace;
    // _pyramidPlace = newPyramidPlace;
    notifyListeners(); // Rebuilds any listening widgets
  }

    void classifySubstantivity(double substantivityValue) {
    if (substantivityValue <= 0.06) {
      _pyramidPlaceController.text = 'top';
    } else if (substantivityValue <= 1.045) {
      _pyramidPlaceController.text = 'top-mid';
    } else if (substantivityValue <= 2.03) {
      _pyramidPlaceController.text = 'mid';
    } else if (substantivityValue <= 3.015) {
      _pyramidPlaceController.text = 'mid-base';
    } else {
      _pyramidPlaceController.text = 'base';
    }
    final test = _pyramidPlaceController.text;
    print("updated pyramid: $test");
    
    notifyListeners(); // Notify listeners that pyramidPlace has changed
  }

    void updateSubstantivity(double newSubstantivity) {
    substantivityController.text = newSubstantivity.toString();
    
    // Only auto-assign pyramidPlace if it's not manually selected by the user
    if (_pyramidPlaceController.text == null || _pyramidPlaceController.text.isEmpty|| _pyramidPlaceController.text=='') {
      print("ENTRE");
      classifySubstantivity(newSubstantivity);

    }
  }

    void updateCostPerGram() {
    double inventoryAmount = double.tryParse(inventoryAmountController.text) ?? 0.0;
    double amountPaid = double.tryParse(amountPaidController.text) ?? 0.0;

    if (inventoryAmount > 0) {
      if (_selectedCurrency == 'Pounds') {
        // Convert pounds to USD using the conversion rate
        amountPaid = amountPaid * _conversionRate;
      }

      _costController.text = (amountPaid / inventoryAmount).toString();
    } else {
      _costController.text = (0.0).toString();
    }

    notifyListeners();
  }

    void updateCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await _service.fetchCategories();
    notifyListeners();
  }



  
}

