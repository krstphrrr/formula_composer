import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formula_composer/features/formula_list/data/formula_list_repositiory.dart';
import 'package:formula_composer/features/formula_list/domain/formula_list_service.dart';
import 'package:formula_composer/features/formula_list/state/formula_list_provider.dart';
import 'package:formula_composer/features/ingredient_list/data/ingredient_list_repository.dart';
import 'package:formula_composer/features/ingredient_list/domain/ingredient_list_service.dart';
import 'core/database/database_helper.dart';
import 'core/providers/theme_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'core/widgets/main_nav_bar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For non-mobile platforms
import 'package:wakelock_plus/wakelock_plus.dart'; // Updated to wakelock_plus
import 'package:provider/provider.dart';

import 'features/formula_add/data/formula_add_repository.dart';
import 'features/formula_add/domain/formula_add_service.dart';
import 'features/formula_add/state/formula_add_provider.dart';
import 'features/ingredient_edit/data/ingredient_edit_repository.dart';
import 'features/ingredient_edit/domain/ingredient_edit_service.dart';
import 'features/ingredient_edit/state/ingredient_edit_provider.dart';
import 'features/ingredient_list/state/ingredient_list_provider.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // // If running on desktop or testing, use sqflite_common_ffi
  if (isDesktopPlatform()) {
    // Initialize FFI for desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; // Set the database factory for FFI
  }

  
  final database = await DatabaseHelper().database;
  final formulaListRepository = FormulaListRepository(database);
  final formulaListService = FormulaListService(formulaListRepository);
  final formulaListProvider = FormulaListProvider(formulaListService);

  final formulaAddRepository = FormulaAddRepository(database);
  final formulaAddService = FormulaAddService(formulaAddRepository);
  final formulaAddProvider = FormulaAddProvider(formulaAddService);

  final ingredientListRepository = IngredientListRepository(database);
  final ingredientListService = IngredientListService(ingredientListRepository);
  final ingredientListProvider = IngredientListProvider(ingredientListService);

  final ingredientEditRepository = IngredientEditRepository(database);
  final ingredientEditService = IngredientEditService(ingredientEditRepository);
  final ingredientEditProvider = IngredientEditProvider(ingredientEditService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => formulaListProvider),
        ChangeNotifierProvider(create: (context) => formulaAddProvider),
        ChangeNotifierProvider(create: (context) => ingredientListProvider),
        ChangeNotifierProvider(create: (context) => ingredientEditProvider),
        // ChangeNotifierProvider(create: (context) => settingsProvider)
      ],
      child: MainApp(),
    ),
  );
}

bool isDesktopPlatform() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    WakelockPlus.enable();
    return MaterialApp(
      // home: Scaffold(
      //   body: Center(
      //     child: Text('Hello World!'),
      //   ),
      // ),
    debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: MainNavBar(),
    );
  }
}
