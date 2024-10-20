import 'package:flutter/material.dart';
import 'package:formula_composer/features/formula_list/presentation/formula_list_item.dart';
import 'package:intl/intl.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FormulaListProvider>(context, listen: false).fetchFormulas();
    });
  }

  void openEditBox(int index) {
    final formulaListProvider =
        Provider.of<FormulaListProvider>(context, listen: false);
    final formulas = formulaListProvider.formulas;
    final formula = formulas[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulaAddPage(
          formula: {
            'id': formula['id'],
            'name': formula['name'],
            'notes': formula['notes'],
            'type': formula['type'],
            'modified_date': formula['modified_date'],
            'creation_date': formula['creation_date']
          },
        ),
      ),
    ).then((_){
      Provider.of<FormulaListProvider>(context, listen: false).fetchFormulas();
    });;
  }

  void openDeleteBox(int index) async{
    final formulaListProvider = Provider.of<FormulaListProvider>(context, listen: false);
    final formulas = formulaListProvider.formulas;
    final formula = formulas[index];

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
      print("TRUEE");
      await formulaListProvider.deleteFormula(formula['id']);
      formulaListProvider.fetchFormulas(); // Refresh the formula list after deletion
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula List'),
        centerTitle: true, // Center the title
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
                      String sub;
                      if(formula["modified_date"]==null){
                        // DateFormat('yyyy-MM-dd').format(formula['creation_date'])
                        sub = 'Created on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(formula['creation_date']))}, Modified on: Not yet modified';
                      } else {
                        sub = 'Created on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(formula['creation_date']))}, Modified on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(formula['modified_date']))}';
                      }

                      return FormulaListItem(
                        title: formula['name'],
                        subtitle: sub,
                        onEditPressed: (context) => openEditBox(index),
                        onDeletePressed: (context) => openDeleteBox(index),
                        onTap: () {
                          print("TAPPED");
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
              ).then((_){
                Provider.of<FormulaListProvider>(context, listen: false).fetchFormulas();
              });
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

