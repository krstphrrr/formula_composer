import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/formula_ing_list_item.dart';
import '../state/formula_ingredient_provider.dart';

class FormulaIngredientPage extends StatefulWidget {
  // final int formulaId;
  final Map<String, dynamic> formula;

  const FormulaIngredientPage(
      {Key? key,
      // required this.formulaId,
      required this.formula})
      : super(key: key);

  @override
  _FormulaIngredientPageState createState() => _FormulaIngredientPageState();
}

class _FormulaIngredientPageState extends State<FormulaIngredientPage> {


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formulaIngredientProvider =
          Provider.of<FormulaIngredientProvider>(context, listen: false);
      formulaIngredientProvider.currentFormulaId = widget.formula['id'];
      formulaIngredientProvider.formulaDisplayName = widget.formula['name'];
      formulaIngredientProvider.fetchFormulaIngredients(widget.formula['id']);
      formulaIngredientProvider.fetchAvailableIngredients();
      formulaIngredientProvider.calculateTotalAmount();
   
    });
  }

  void _showAddIngredientModal(BuildContext context) {
    final formulaIngredientProvider =
        Provider.of<FormulaIngredientProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // To allow the sheet to expand and provide more space if needed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height *
                0.75, // Adjust the height as needed
            child: Column(
              children: [
                TextField(
                  controller: formulaIngredientProvider.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ingredients by name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    formulaIngredientProvider.filterAvailableIngredients(value);
                  },
                ),
                const SizedBox(height: 10), // Add some spacing
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        formulaIngredientProvider.filteredIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient =
                          formulaIngredientProvider.filteredIngredients[index];
                      return ListTile(
                        title: Text(ingredient['name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            // formulaIngredientProvider.addIngredientToFormula(index, ingredient['id']);
                            formulaIngredientProvider.addIngredientRow(
                                context, index);
                            Navigator.pop(
                                context); // Close the bottom sheet once an ingredient is added
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final formulaIngredientProvider = Provider.of<FormulaIngredientProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Ingredients'),
      ),
      body: Column(
        children: [
          Expanded(child: Consumer<FormulaIngredientProvider>(
            builder: (context, formulaIngredientProvider, child) {
              return Column(children: [
                Text(
                    'Total Amount: ${formulaIngredientProvider.totalAmount.toStringAsFixed(2)} grams'), // Display total amount
                Expanded(
                    child: formulaIngredientProvider.formulaIngredients.isEmpty
                        ? Center(child: Text('No ingredients available'))
                        : ListView.builder(
                            itemCount: formulaIngredientProvider
                                .formulaIngredients.length,
                            itemBuilder: (context, index) {
                              //  access controllers safely
                              //     if (index < formulaIngredientProvider.amountControllers.length &&
                              //  index < formulaIngredientProvider.dilutionControllers.length) {
                              final ingredient = formulaIngredientProvider
                                  .formulaIngredients[index];
                              final amountController = formulaIngredientProvider
                                  .amountControllers[index];
                              final dilutionController =
                                  formulaIngredientProvider
                                      .dilutionControllers[index];
                              //  final ingredient['name'] = formulaIngredientProvider.

                              final amountFocusNode = formulaIngredientProvider.amountFocusNodes
                                                    .isNotEmpty &&
                                                index <
                                                    formulaIngredientProvider.amountFocusNodes.length
                                            ? formulaIngredientProvider.amountFocusNodes[index]
                                            : null;
                              final dilutionFocusNode = formulaIngredientProvider.dilutionFocusNodes
                                                    .isNotEmpty &&
                                                index <
                                                    formulaIngredientProvider.dilutionFocusNodes.length
                                            ? formulaIngredientProvider.dilutionFocusNodes[index]
                                            : null;

                              double dilution =
                                  double.tryParse(dilutionController.text) ??
                                      1.0;
                              double relativeAmount =
                                  (formulaIngredientProvider.totalAmount > 0)
                                      ? (ingredient['amount'] *
                                          dilution /
                                          formulaIngredientProvider.totalAmount)
                                      : 0.0;

                              return FormulaIngredientListItem(
                                title: ingredient['name'],
                                amountController: amountController,
                                dilutionController: dilutionController,
                                relativeAmountText:
                                    (relativeAmount * 100).toStringAsFixed(2),
                                amountFocusNode: amountFocusNode,
                                dilutionFocusNode: dilutionFocusNode,
                                onChangedAmount: (value){
                                  double amount = double.tryParse(value) ?? 0.0;
                                  double dilution = double.tryParse(dilutionController.text) ?? 1.0;
                                  print("AM VALUE CHANGED: ${value}");
 
                                  formulaIngredientProvider.updateIngredientInFormula(
                                                index,
                                                ingredient['ingredient_id'],
                                                amount,
                                                dilution);
                                },
                                onChangedDilution: (value){
                                  double dilution = double.tryParse(value) ?? 1.0;
                                   print("DIL VALUE CHANGED: ${value}");
                                  if (ingredient['ingredient_id'] !=
                                              null) {
                                            formulaIngredientProvider
                                                .updateDilutionFactor(
                                                    index, value);
                                            formulaIngredientProvider
                                                .updateIngredientInFormula(
                                                    index,
                                                    ingredient[
                                                        'ingredient_id']!,
                                                    ingredient['amount'],
                                                    dilution);
                                          } else {
                                            print(
                                                "Warning: ingredient_id is null for index $index");
                                          }

                                },
                                onDeletePressed: () {
                                  formulaIngredientProvider
                                      .removeIngredient(index);
                                },
                              );
                            }))
              ]);
            },
          )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: "saveFab",
                  onPressed: () async {
                    final formulaIngredientProvider =
                        Provider.of<FormulaIngredientProvider>(context,
                            listen: false);
                    // await formulaIngredientProvider.saveAllChanges(formulaIngredientProvider.currentFormulaId!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All changes saved successfully')),
                    );
                  },
                  child: const Icon(Icons.save),
                  mini: true,
                ),
                FloatingActionButton.extended(
                  heroTag: "addFab",
                  onPressed: () {
                    final formulaIngredientProvider =
                        Provider.of<FormulaIngredientProvider>(context,
                            listen: false);
                    _showAddIngredientModal(context);
                    // formulaIngredientProvider.addIngredientRow(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

