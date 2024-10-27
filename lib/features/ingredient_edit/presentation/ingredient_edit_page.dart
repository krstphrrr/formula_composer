import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../ingredient_list/state/ingredient_list_provider.dart';
import '../state/ingredient_edit_provider.dart';

class IngredientEditPage extends StatefulWidget {
  final int? ingredientId;
  const IngredientEditPage({required this.ingredientId});

  @override
  _IngredientEditPageState createState() => _IngredientEditPageState();
}

class _IngredientEditPageState extends State<IngredientEditPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ingredientEditProvider =
          Provider.of<IngredientEditProvider>(context, listen: false);
      ingredientEditProvider.fetchCategories();
      if (widget.ingredientId != null) {
        ingredientEditProvider.selectedIngredient = widget.ingredientId;
        ingredientEditProvider.loadIngredientDetails();
      } else {
        // ingredientEditProvider.selectedIngredient = null;
        ingredientEditProvider.clearControllers();
      }
    });
  }

  void _saveIngredient() {
    final ingredientEditProvider =
        Provider.of<IngredientEditProvider>(context, listen: false);

    // Create a new Map instead of trying to modify a read-only QueryRow object
    final newIngredient = {
      'name': ingredientEditProvider.commonNameController.text,
      'category': ingredientEditProvider.categoryController.text,
      'inventory_amount':
          double.tryParse(ingredientEditProvider.inventoryAmountController.text) ??
              0.0,
      'cost_per_gram':
          double.tryParse(ingredientEditProvider.costController.text) ?? 0.0,
      'supplier': ingredientEditProvider.supplierController.text,
      'acquisition_date': ingredientEditProvider.acquisitionDateController.text,
      'description': ingredientEditProvider.descriptionController.text,
      'personal_notes': ingredientEditProvider.personalNotesController.text,
      'supplier_notes': ingredientEditProvider.supplierNotesController.text,
      // 'molecular_weight':
      //     double.tryParse(ingredientEditProvider.molecularWeightController.text) ??
      //         0.0,
      'pyramid_place': ingredientEditProvider.pyramidPlaceController.text,
      'substantivity':
          double.tryParse(ingredientEditProvider.substantivityController.text) ??
              0.0, // Handle null
      // 'cas_numbers': ingredientEditProvider.casNumbers, // Assuming this is a list of CAS numbers
    };

    print("Adding new ingredient with name: $newIngredient");

    if (widget.ingredientId == null) {
      // Add new ingredient logic here
      ingredientEditProvider.addIngredient(
          newIngredient, ingredientEditProvider.casNumbers);
    } else {
      // Update existing ingredient logic here
      ingredientEditProvider.updateIngredient(
          newIngredient, ingredientEditProvider.casNumbers);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      // Update the provider's acquisition date
      Provider.of<IngredientEditProvider>(context, listen: false)
          .updateAcquisitionDate(formattedDate);
    }
  }

  void _showSubstantivityDialog() {
    final ingredientEditProvider =
        Provider.of<IngredientEditProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calculate Substantivity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ingredientEditProvider.hoursController,
                decoration: const InputDecoration(labelText: 'Hours'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ingredientEditProvider.concentrationController,
                decoration:
                    const InputDecoration(labelText: 'Concentration (%)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Validate input and calculate normalized substantivity
                double hours =
                    double.tryParse(ingredientEditProvider.hoursController.text) ??
                        0.0;
                double concentration = double.tryParse(
                        ingredientEditProvider.concentrationController.text) ??
                    1.0;
                if (concentration == 0) {
                  concentration = 1.0; // Prevent division by zero
                }
                double normalizedSubstantivity = hours / concentration;

                // Automatically update the substantivity and pyramid place if not selected
                ingredientEditProvider.updateSubstantivity(normalizedSubstantivity);

                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCostCalculationDialog(BuildContext context) async {
    final provider =
        Provider.of<IngredientEditProvider>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Calculate Cost per Gram'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: provider.inventoryAmountController,
                decoration:
                    InputDecoration(labelText: 'Inventory Amount (grams)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: provider.amountPaidController,
                decoration: InputDecoration(
                    labelText: 'Amount Paid (in ${provider.selectedCurrency})'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: provider.selectedCurrency,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    provider.updateCurrency(newValue);
                  }
                },
                items: <String>['USD', 'Pounds']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                provider.clearControllers();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Calculate'),
              onPressed: () {
                provider.updateCostPerGram(); // Call to update cost per gram
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownCategory(BuildContext context) {
  final ingredientEditProvider = Provider.of<IngredientEditProvider>(context);


  String? currentCategory = ingredientEditProvider.categoryController.text;

  return Consumer<IngredientListProvider>(
    builder: (context, provider, child) {
      return DropdownButtonFormField<String>(
        value: ingredientEditProvider.categories.contains(currentCategory)
            ? currentCategory
            : null,
        decoration: const InputDecoration(labelText: 'Category'),
        items: ingredientEditProvider.categories.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            ingredientEditProvider.updateCategory(newValue);
          }
        },
      );
    },
  );
}

  Widget _buildDropdownPyramidPlace(
      BuildContext context, String label, List<String> values) {
    final ingredientEditProvider = Provider.of<IngredientEditProvider>(context);

    // Ensure that the current value is in the list of dropdown values
    String? currentPyramidPlace =
        ingredientEditProvider.pyramidPlaceController.text;

    return DropdownButtonFormField<String>(
      value:
          currentPyramidPlace, // Ensure that the value is in the list of items
      decoration: InputDecoration(labelText: label),
      items: values.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          ingredientEditProvider.updatePyramidPlace(
              newValue); // Update the pyramid place when selected
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a value';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredientEditProvider = Provider.of<IngredientEditProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Ingredient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ingredient Name'),
                // initialValue: commonName,
                controller: ingredientEditProvider.commonNameController,
              ),
              TextField(
                controller: ingredientEditProvider.casController,
                decoration: InputDecoration(
                  labelText: 'Add or Edit CAS Number',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: ingredientEditProvider
                        .confirmCASNumber, // Confirm the CAS number
                  ),
                ),
                onSubmitted: (_) => ingredientEditProvider
                    .confirmCASNumber(), // Confirm on Enter key
              ),

              // Display confirmed CAS numbers as chips
              Wrap(
                spacing: 8.0,
                children: ingredientEditProvider.casNumbers.map((cas) {
                  return Chip(
                      label: Text(cas),
                      onDeleted: () => ingredientEditProvider.removeCASNumber(cas));
                }).toList(),
              ),

              _buildDropdownCategory(
                  context,), // Call modified _buildDropdown
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Inventory Amount (grams)'),
                // initialValue: inventoryAmount.toString(),
                keyboardType: TextInputType.number,
                controller: ingredientEditProvider.inventoryAmountController,
                //   onChanged: (value) =>
                //       inventoryAmount = double.tryParse(value) ?? 0.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Cost per Gram'),
                      // initialValue: costPerGram.toString(),
                      keyboardType: TextInputType.number,
                      controller: ingredientEditProvider.costController,
                      //   onChanged: (value) =>
                      //       costPerGram = double.tryParse(value) ?? 0.0,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calculate),
                    onPressed: () {
                      _showCostCalculationDialog(context);
                    }, // Trigger the dialog
                  ),
                ],
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Supplier'),
                controller: ingredientEditProvider.supplierController,
                // initialValue: supplier,
                // onChanged: (value) => supplier = value,
              ),
              ListTile(
                title: const Text('Acquisition Date'),
                subtitle: Text(
                  ingredientEditProvider.acquisitionDateController.text.isEmpty
                      ? 'Select a date'
                      : ingredientEditProvider.acquisitionDateController
                          .text, // Use the text from the controller
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: ingredientEditProvider
                            .acquisitionDateController.text.isNotEmpty
                        ? DateTime.parse(ingredientEditProvider
                            .acquisitionDateController
                            .text) // Parse existing date
                        : DateTime
                            .now(), // Default to today if no date is selected
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    // Update the provider with the selected date
                    final formattedDate = pickedDate
                        .toIso8601String()
                        .split('T')
                        .first; // Format the date as YYYY-MM-DD
                    ingredientEditProvider.updateAcquisitionDate(formattedDate);
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                controller: ingredientEditProvider.descriptionController,
                // initialValue: description,
                // onChanged: (value) => description = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Personal Notes'),
                controller: ingredientEditProvider.personalNotesController,
                // initialValue: personalNotes,
                // onChanged: (value) => personalNotes = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Supplier Notes'),
                controller: ingredientEditProvider.supplierNotesController,
                // initialValue: supplierNotes,
                // onChanged: (value) => supplierNotes = value,
              ),
              // TextFormField(
              //   decoration:
              //       const InputDecoration(labelText: 'Molecular Weight'),
              //   // initialValue: molecularWeight.toString(),
              //   controller: ingredientEditProvider.molecularWeightController,
              //   keyboardType: TextInputType.number,
              //   // onChanged: (value) =>
              //   //     molecularWeight = double.tryParse(value) ?? 0.0,
              // ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ingredientEditProvider.substantivityController,
                      decoration:
                          const InputDecoration(labelText: 'Substantivity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calculate),
                    onPressed: _showSubstantivityDialog, // Trigger the dialog
                  ),
                ],
              ),

              _buildDropdownPyramidPlace(context, 'Pyramid Place',
                  _pyramidPlaceValues()), // Pyramid Place dropdown

              ElevatedButton(
                onPressed: () {
                  _saveIngredient();
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    if (ingredientEditProvider
                        .acquisitionDateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please select an acquisition date.')),
                      );
                      return;
                    }
                    // If adding a new ingredient
                    if (widget.ingredientId == null) {
                      print('from page: adding ');
                    } else {
                      print("from page: updating");
                    }
                    // After update, fetch updated data
                    Provider.of<IngredientListProvider>(context, listen: false).fetchIngredients();

                    Navigator.of(context)
                        .pop(); // Return to the previous page after saving
                  }
                },
                child: Text(widget.ingredientId == null ? 'Add' : 'Update'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Dropdown values for category
List<String> _categoryValues() {
  return [
    'aldehydic',
    'ambery',
    'citrus',
    'floral',
    'fruity',
    'gourmand',
    'green',
    'herbal',
    'agrestic',
    'leather',
    'moss',
    'marine',
    'musky',
    'spicy',
    'terpenic',
    'woody'
  ];
}

// Dropdown values for pyramid place
List<String> _pyramidPlaceValues() {
  return ['', 'top', 'top-mid', 'mid', 'mid-base', 'base'];
}
