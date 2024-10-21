import 'package:flutter/material.dart';
import 'package:formula_composer/features/ingredient_list/state/ingredient_list_provider.dart';
import 'package:provider/provider.dart';

import '../../ingredient_edit/presentation/ingredient_edit_page.dart';
import 'ingredient_list_item.dart';

class IngredientListPage extends StatefulWidget {
  const IngredientListPage({ Key? key }) : super(key: key);

  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {

  void openDeleteBox(int index){

  }

  void openEditBox(int index){

  }

  @override
  Widget build(BuildContext context) {
    final ingredientListProvider = Provider.of<IngredientListProvider>(context, listen: false);

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

                      return IngredientListItem(
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
                  MaterialPageRoute(builder: (context) => const IngredientEditPage()),
                ).then((_) {
                  setState(() {
                  ingredientListProvider.fetchIngredients();  // Rebuild after fetching ingredients
                });
                });
              },
              label: const Text('Add Ingredient to inventory'), // Label for empty list
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
                MaterialPageRoute(builder: (context) => const IngredientEditPage()),
              ).then((_) {
                setState(() {
                  ingredientListProvider.fetchIngredients();  // Rebuild after fetching ingredients
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

