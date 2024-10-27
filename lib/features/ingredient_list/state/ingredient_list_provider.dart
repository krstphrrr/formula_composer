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

  final Map<String, Color> _categoryColorCache = {};

  int get totalIngredients => _ingredients.length;

  Map<String, Color> _categoryColors = {};

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
  Future <void> fetchIngredients() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      // _casController.clear();
      _ingredients = await _service.fetchIngredients();
      _filteredIngredients = _ingredients;

      // Assign colors based on category if available
    for (var ingredient in _ingredients) {
      final category = ingredient['category'];
      if (_categoryColors.containsKey(category)) {
        ingredient['color'] = _categoryColors[category];
      }
    }
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

  void sortIngredients(String criterion) {

   // Define a mapping for pyramid places to their sort order
  final Map<String, int> pyramidPlaceOrder = {
    'base': 1,
    'mid-base': 2,
    'mid': 3,
    'top-mid': 4,
    'top': 5,
  };
  _filteredIngredients.sort((a, b) {
    switch (criterion) {
      case 'cost':
      // Use null-aware operators and default values to prevent errors
      double costA = double.tryParse(a['cost_per_gram']?.toString() ?? '0') ?? 0.0;
      double costB = double.tryParse(b['cost_per_gram']?.toString() ?? '0') ?? 0.0;
      // Parse as double for numeric sorting
        return costA
            .compareTo(costB);
      case 'substantivity':
        double substantivityA = double.tryParse(a['substantivity']?.toString() ?? '0') ?? 0.0;
        double substantivityB = double.tryParse(b['substantivity']?.toString() ?? '0') ?? 0.0;
        // Parse as double for numeric sorting
        return substantivityA
            .compareTo(substantivityB);
      case 'acquisition_date':
        // Parse as DateTime for date sorting
        DateTime dateA = DateTime.parse(a[criterion].toString());
        DateTime dateB = DateTime.parse(b[criterion].toString());
        return dateA.compareTo(dateB);

       case 'pyramid':
        // Sort by pyramid place first
        final int orderA = pyramidPlaceOrder[a['pyramidPlace']] ?? 6; // Default if not found
        final int orderB = pyramidPlaceOrder[b['pyramidPlace']] ?? 6;
        if (orderA != orderB) {
          return orderA.compareTo(orderB);
        } else {
          // If pyramid places are the same, sort by substantivity within the same pyramid place
          double substantivityA = double.tryParse(a['substantivity']?.toString() ?? '0') ?? 0.0;
          double substantivityB = double.tryParse(b['substantivity']?.toString() ?? '0') ?? 0.0;
          return substantivityB.compareTo(substantivityA); // Higher substantivity first
        }

      case 'name':
      default:
        // Default to string comparison for alphabetical sorting
        return a[criterion].toString().compareTo(b[criterion].toString());
    }
  });
  
  if (isReverseSortEnabled) {
    _filteredIngredients = _filteredIngredients.reversed.toList();
  }

  notifyListeners();
}

  void reverseSort() {
    isReverseSortEnabled = !isReverseSortEnabled;
    _filteredIngredients = _filteredIngredients.reversed.toList();
    notifyListeners();
  }

  
  Future<void> importData(BuildContext context) async {
    isImporting = true;
    notifyListeners();
    try {
      final result = await _service.pickCSVLocation();
      if (result != null) {
        String filePath = result.files.single.path!;
        await _service.importFromCSV(filePath);
        // Check if the widget is still mounted before showing the Snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data imported successfully!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to import csv: $e')));
      }
    } finally {
      isImporting = false;
      notifyListeners();
    }
  }

    Future<void> exportData(BuildContext context) async {
    isExporting = true;
    notifyListeners();
    // 1. select save location and pass path
    // 2. if path is not null, use exportcsv to that file path (service)

    try {
      String? filePath = await _service.exportPathPicker();
      // Assuming a method to save the CSV file
      // await _saveCsvFile(csvData);

      if (filePath != null) {
        _service.exportCSV(filePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data exported successfully!')));
        }
      } else {
        // Show error message if file picker result is null (user canceled or failed to pick)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to select file for export.')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<Color> getCategoryColor(String categoryName) async {
    // Check if color is already in cache
    // if (_categoryColorCache.containsKey(categoryName)) {
    //   return _categoryColorCache[categoryName]!;
    // }

    // Fetch color from service and cache it
    final color = await _service.getCategoryColor(categoryName);
    _categoryColorCache[categoryName] = color;
    return color;
  }

  // Method to update a specific category's color
  void updateCategoryColor(String category, Color color) {
    _categoryColors[category] = color;

    // Update colors in the ingredient list as well
    for (var ingredient in _ingredients) {
      if (ingredient['category'] == category) {
        ingredient['color'] = color;
      }
    }

    notifyListeners(); // Notify to refresh UI with new color
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
