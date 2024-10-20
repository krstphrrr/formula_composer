import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../formula_add/presentation/formula_add_page.dart';
import '../state/formula_list_provider.dart';

class FormulaListPage extends StatefulWidget {
  const FormulaListPage({Key? key}) : super(key: key);

  @override
  _FormulaListPageState createState() => _FormulaListPageState();
}

class _FormulaListPageState extends State<FormulaListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch formulas when the page is initialized
    // WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FormulaListProvider>(context, listen: false).fetchFormulas();
    // });
  }

  void openEditBox() {
    // prefill

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Edit Formula"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [],
            )
            // actions: [
            //   // _cancelButton(),

            //   // _saveButton()
            // ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula List'),
        centerTitle: true, // Center the title

        actions: [
          // IconButton(
          //   icon: const Icon(Icons.color_lens),
          //   onPressed: () {
          //     themeProvider.toggleTheme(); // Switch the theme when the button is pressed
          //   },
          // ),
          // Button for navigating to the ingredient list page
          // IconButton(
          //   icon: const Icon(Icons.list), // Choose an appropriate icon
          //   onPressed: () {
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(builder: (context) => IngredientsListPage()),
          //     // );
          //   },
          // ),

          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Perform the async operation
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const FormulaManagementPage()),
              // // );

              // if (mounted) {
              //   formulaProvider.fetchFormulas();
              // }
            },
          ),
        ],
      ),
      body: Consumer<FormulaListProvider>(
        builder: (context, formulaListProvider, child) {
          final formulas = formulaListProvider.formulas;
          if (formulaListProvider.isLoading) {
            // Show loading spinner while fetching data
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (formulaListProvider.formulas.isEmpty) {
            // Show message if no formulas are found
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('No formulas found in the database.')],
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: formulaListProvider.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search formulas by name',
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
                    itemCount: formulas.length,
                    itemBuilder: (context, index) {
                      final formula = formulas[index];

                      return ListTile(
                        title: Text(formula['name']),
                        subtitle: Text('Type: ${formula['type']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final formulaListProvider =
                                Provider.of<FormulaListProvider>(context,
                                    listen: false);
                            // Show a confirmation dialog before deletion
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Formula'),
                                  content: const Text(
                                      'Are you sure you want to delete this formula?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await formulaListProvider.deleteFormula(formula['id']);
                              formulaListProvider.fetchFormulas(); // Refresh the formula list after deletion
                            }
                          },
                        ),
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         FormulaDetailsPage(formula: formula),
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
      floatingActionButton: SizedBox(
          height: 70, // Adjust height
          width: 70, // Adjust width
          child: FloatingActionButton(
            onPressed: () {
              // Perform the async operation
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormulaAddPage()),
              );

              if (mounted) {
                final formulaListProvider =
                    Provider.of<FormulaListProvider>(context, listen: false);
                formulaListProvider.fetchFormulas();
              }
            },
            child: const Icon(
              Icons.add,
              size: 30,
              ),
            tooltip: 'Add Formula',
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Position FAB in lower center
    );
  }
}
