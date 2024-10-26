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
          ingredientId: ingredient[index],
        ),
      ),
    ).then((_) {
      Provider.of<IngredientListProvider>(context, listen: false)
          .fetchIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ingredientListProvider =
        Provider.of<IngredientListProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Inventory'),
        centerTitle: true,
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
                Expanded(
                  child: ListView.builder(
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      String sub = '';

                      return CustomListItem(
                        title: ingredient['name'],
                        subtitle: sub,
                        onEditPressed: (context) => openEditBox(index),
                        onDeletePressed: (context) => openDeleteBox(index),
                        onTap: () {
                          print("TAPPED");
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         IngredientDetailsPage(ingredient: ingredient),
                          //   ),
                          // );
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
