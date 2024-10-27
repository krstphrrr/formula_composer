import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/ingredient_list_repository.dart';

class IngredientListService {
  static const platform = MethodChannel('com.example.formula/file_operations');

  final IngredientListRepository _repository;

  IngredientListService(this._repository);

  Future<List<Map<String, dynamic>>> fetchIngredients() async {
    return await _repository.fetchAllIngredients();
  }

  Future<void> deleteIngredient(int id) async {
    try {
      await _repository.deleteIngredient(id);
    } catch (e) {
      // if (kDebugMode) {
      print("ingredient_service: Error deleting ingredients: $e");
      // }
    }
  }

  Future<String?> exportPathPicker() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'export.csv', // Default file name
      type: FileType.custom,
      bytes: Uint8List(0),
      allowedExtensions: ['csv'], // Only allow CSV files
    );
    return filePath;
  }

  Future<void> exportCSV(String directory) async {



    try {
      final ingredients = await _repository.fetchAllIngredients();
      // Count the number of ingredients
    int ingredientCount = ingredients.length;
      // Get the current date
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  
  // Construct the file name with ingredient count and current date
  String fileName = '_${ingredientCount}ing_$currentDate.csv';
  directory = directory.replaceAll('.csv', '');

  // Combine directory path and file name
  String filePath = '$directory$fileName';

      // / Prepare the CSV data for ingredients
      List<List<String>> ingredientsCsvData = [
        [
          "id",
          "name",
          "category",
          "inventory_amount",
          "cost_per_gram",
          "supplier",
          "acquisition_date",
          "description",
          "personal_notes",
          "supplier_notes",
          // "molecular_weight",
          "pyramid_place",
          "casNumber",
          "substantivity"
        ],
        ...ingredients.map((ingredient) => [
              (ingredient['id'] ?? '').toString(),
              (ingredient['name'] ?? '').toString(),
              (ingredient['category'] ?? '').toString(),
              (ingredient['cas_number'] ?? '').toString(), // Include the cas_number field
              (ingredient['inventory_amount'] ?? 0).toString(),
              (ingredient['cost_per_gram'] ?? 0).toString(),
              (ingredient['supplier'] ?? '').toString(),
              (ingredient['acquisition_date'] ?? '').toString(),
              (ingredient['description'] ?? '').toString(),
              (ingredient['personal_notes'] ?? '').toString(),
              (ingredient['supplier_notes'] ?? '').toString(),
              // (ingredient['molecular_weight'] ?? 0).toString(),
              (ingredient['pyramid_place'] ?? '').toString(),
              (ingredient['casNumber'] ?? '').toString(),
              (ingredient['substantivity'] ?? '').toString()
            ]),
      ];

      String csvContent =
          const ListToCsvConverter().convert(ingredientsCsvData);
      // Check if the file path is a 'content://' URI
      if (filePath.startsWith('content://')) {
        // Use the method channel to write to content URI via Kotlin
        await platform.invokeMethod(
            'writeToContentUri', {'uri': filePath, 'csvContent': csvContent});
      } else {
        // Handle normal file paths using Flutter's File API
        final file = File(filePath);
        await file.writeAsString(csvContent);
      }

      print('Data exported successfully!');
    } on PlatformException catch (e) {
      print('Failed to export CSV: ${e.message}');
    } catch (e) {
      print('Error during export: $e');
    }
  }

    Future<FilePickerResult?> pickCSVLocation() async {
    // Use file picker to select CSV file
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'], // Only allow CSV files
    );
  }

  Future<void> importFromCSV(String filePath) async {
    final file = File(filePath);
    final csvString = await file.readAsString();

    // Convert CSV to list
    List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

    for (var i = 1; i < csvData.length; i++) {
      // Skip the header row
      final row = csvData[i];

      // Convert values to string if necessary
      final ingredient = {
        'name': row[1].toString(),
        'category': row[2].toString(),
        'inventory_amount': double.tryParse(row[3].toString()) ?? 0.0,
        'cost_per_gram': double.tryParse(row[4].toString()) ?? 0.0,
        'supplier': row[5].toString(),
        'acquisition_date': row[6].toString(),
        'description': row[7].toString(),
        'personal_notes': row[8].toString(),
        'supplier_notes': row[9].toString(),
        // 'molecular_weight': double.tryParse(row[10].toString()) ?? 0.0,
        'pyramid_place': row[11].toString(),
        'substantivity': row[12].toString(),
        'cas_number': row[13].toString()
      };
      
      // Insert into the database
      await _repository.insertIngredientIntoDatabase(ingredient);
    }
  }

    Future<Color> getCategoryColor(String categoryName) async {
    // Fetch the hex color code from the repository
    final colorHex = await _repository.getCategoryColor(categoryName);
    print("cat: ${categoryName} color: ${colorHex}");

    // If color is null (not set), provide a default color, else parse the color
    return colorHex != null
        ? Color(int.parse(colorHex.replaceFirst('#', '0xFF'))) // Convert hex to Color
        : Colors.grey; // Default color if none set
  }
}
