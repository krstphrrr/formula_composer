import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ingredient_edit/presentation/ingredient_edit_page.dart';

import '../state/ingredient_view_provider.dart';


class IngredientViewPage extends StatefulWidget {
  final int ingredientId;

  IngredientViewPage({required this.ingredientId});

  @override
  _IngredientViewPageState createState() => _IngredientViewPageState();
}

class _IngredientViewPageState extends State<IngredientViewPage> {
  @override
  void initState() {
    super.initState();
    // Fetch ingredient details using the provider when the page is initialized.
     WidgetsBinding.instance.addPostFrameCallback((_) {
final ingredientProvider =
        Provider.of<IngredientViewProvider>(context, listen: false);
    ingredientProvider.fetchIngredientDetails(widget.ingredientId);
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingredient Details'),
      ),
      body: Consumer<IngredientViewProvider>(
        builder: (context, provider, child) {
          final ingredient = provider.ingredients;

          if (ingredient == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${ingredient['name']}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Cost per gram: \$${(ingredient['cost_per_gram'] ?? 0.0).toStringAsFixed(2)}',
                ),
                Text(
                  'Substantivity: ${ingredient['substantivity']}',
                ),
                // Add more fields as needed
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IngredientEditPage(ingredientId: widget.ingredientId),
                      ),
                    );
                  },
                  child: Text('Edit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
