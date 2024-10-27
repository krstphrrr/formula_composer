import 'package:flutter/material.dart';
import 'package:formula_composer/features/ingredient_edit/state/ingredient_edit_provider.dart';
import 'package:formula_composer/features/ingredient_list/state/ingredient_list_provider.dart';
import 'package:provider/provider.dart';

import '../../ingredient_edit/presentation/ingredient_edit_page.dart';
import '../../../core/widgets/custom_list_item.dart';

class IngredientListPage extends StatefulWidget {
  const IngredientListPage({Key? key}) : super(key: key);

  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ingredientProvider =
          Provider.of<IngredientListProvider>(context, listen: false);
      ingredientProvider.fetchIngredients(); // Fetch ingredients when the page loads
    });
  }

  Future<void> openDeleteBox(int index) async {
    final ingredientListProvider =
        Provider.of<IngredientListProvider>(context, listen: false);
    final ingredients = ingredientListProvider.ingredients;
    final ingredient = ingredients[index];

    // Show a confirmation dialog before deletion
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Formula'),
          content:
              const Text('Are you sure you want to delete this ingredient?'),
          actions: [
            TextButton(
              onPressed: () => {
                Navigator.of(context).pop(false),
                setState(() {
                  ingredientListProvider
                      .fetchIngredients(); // Rebuild after fetching ingredients
                }),
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => {
                Navigator.of(context).pop(true),
                setState(() {
                  ingredientListProvider
                      .fetchIngredients(); // Rebuild after fetching ingredients
                }),
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      print("TRUEE");
      await ingredientListProvider.deleteIngredient(ingredient['id']);

      setState(() {
        ingredientListProvider
            .fetchIngredients(); // Rebuild after fetching ingredients
        Provider.of<IngredientEditProvider>(context, listen: false)
            .clearControllers();
      });
    }
  }

  void openEditBox(int index) {
    final ingredientListProvider =
        Provider.of<IngredientListProvider>(context, listen: false);
    final ingredients = ingredientListProvider.ingredients;
    final ingredient = ingredients[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientEditPage(
          ingredientId: ingredient['id'],
        ),
      ),
    ).then((_) {
      Provider.of<IngredientListProvider>(context, listen: false)
          .fetchIngredients();
    });
  }

  void _showSortDialog() {
    final ingredientProvider =
        Provider.of<IngredientListProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Name'),
                onTap: () {
                  Navigator.pop(context);
                  ingredientProvider.sortIngredients('name');
                },
              ),
              ListTile(
                title: const Text('Acquisition Date'),
                onTap: () {
                  Navigator.pop(context);
                  ingredientProvider.sortIngredients('acquisition_date');
                },
              ),
              ListTile(
                title: const Text('Cost'),
                onTap: () {
                  Navigator.pop(context);
                  ingredientProvider.sortIngredients('cost');
                },
              ),
              ListTile(
                title: const Text('Substantivity'),
                onTap: () {
                  Navigator.pop(context);
                  ingredientProvider.sortIngredients('substantivity');
                },
              ),
              ListTile(
                title: Text('Sort by Pyramid Placement'),
                onTap: () {
                  Navigator.of(context).pop();
                  ingredientProvider
                      .sortIngredients('pyramid'); // Normal sort order
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredientListProvider =
        Provider.of<IngredientListProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Inventory'),
        actions: [
            // Export Button
            IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: () {
                ingredientListProvider.exportData(context);
              }, // Call export function
            ),
            // Import Button
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () {
                ingredientListProvider.importData(context);
              }, // Call import function,
            ),
        ],
      ),
      body: Consumer<IngredientListProvider>(
        builder: (context, ingredientListProvider, child) {
          final ingredients = ingredientListProvider.ingredients;
          if (ingredientListProvider.isLoading) {
            // Show loading spinner while fetching data
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (ingredientListProvider.ingredients.isEmpty) {
            // Show message if no ingredients are found
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('No ingredients found in the database.')],
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: ingredientListProvider.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ingredients by name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) {
                      // Implement search functionality if needed
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _showSortDialog,
                      child: const Text('Sort'),
                    ),
                    // Display the total number of ingredients
                    Text(
                      'Total: ${ingredientListProvider.totalIngredients}',
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: ingredientListProvider.reverseSort,
                      child: const Text('Reverse Sort'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      String assetPath =
                          'assets/images/4x/none_xxxhdpi.png'; // Default asset
                      switch (ingredient['pyramid_place']) {
                        case 'top':
                          assetPath = 'assets/images/4x/top_xxxhdpi.png';
                          break;
                        case 'top-mid':
                          assetPath = 'assets/images/4x/top_mid_xxxhdpi.png';
                          break;
                        case 'mid':
                          assetPath = 'assets/images/4x/mid_xxxhdpi.png';
                          break;
                        case 'mid-base':
                          assetPath = 'assets/images/4x/mid-base_xxxhdpi.png';
                          break;
                        case 'base':
                          assetPath = 'assets/images/4x/base_xxxhdpi.png';
                          break;
                        default:
                          assetPath = 'assets/images/4x/none_xxxhdpi.png';
                          break;
                      }
                      String sub = 'Cost: \$${ingredient['cost_per_gram']}, Substantivity: ${ingredient['substantivity']}';

                      return FutureBuilder<Color>(
                              future: ingredientListProvider.getCategoryColor(ingredient['category']),
                              builder: (context, snapshot) {
                                final categoryColor = snapshot.data ?? Colors.grey; // Default color if loading
                                return CustomListItem(
                                  title: ingredient['name'],
                                  subtitle: 'Cost: \$${ingredient['cost_per_gram']}, Substantivity: ${ingredient['substantivity']}',
                                  onEditPressed: (context) => openEditBox(index),
                                  onDeletePressed: (context) => openDeleteBox(index),
                                  centerImage: AssetImage(assetPath),
                                  categoryColor: categoryColor,
                                  onTap: () async{
                                    print(await ingredientListProvider.getCategoryColor(ingredient['category']));
                                    print(ingredient);
                                    
                                  },
                                );
                              },
                            );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: Consumer<IngredientListProvider>(
        builder: (context, ingredientListProvider, child) {
          final ingredients = ingredientListProvider.ingredients;

          // If the list is empty, show 'Create ingredient' button in the center
          if (ingredients.isEmpty) {
            return SizedBox(
              height: 70,
              width: 230,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const IngredientEditPage(ingredientId: null)),
                  ).then((_) {
                    setState(() {
                      ingredientListProvider
                          .fetchIngredients(); // Rebuild after fetching ingredients
                    });
                  });
                },
                label: const Text(
                    'Add Ingredient to inventory'), // Label for empty list
                icon: const Icon(Icons.add), // Icon with the label
                tooltip: 'Create a new ingredient',
              ),
            );
          } else {
            // If there are ingredients, show 'plus' button in the bottom right
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const IngredientEditPage(ingredientId: null)),
                ).then((_) {
                  setState(() {
                    ingredientListProvider
                        .fetchIngredients(); // Rebuild after fetching ingredients
                  });
                });
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Ingredient',
            );
          }
        },
      ),
      floatingActionButtonLocation: ingredientListProvider.ingredients.isEmpty
          ? FloatingActionButtonLocation.centerFloat // Center if empty
          : FloatingActionButtonLocation.endFloat, // Bottom right if not empty
    );
  }
}
//  add optional properties to custom item widget
