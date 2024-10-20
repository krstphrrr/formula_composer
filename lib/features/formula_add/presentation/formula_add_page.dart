import 'package:flutter/material.dart';
import '../state/formula_add_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FormulaAddPage extends StatefulWidget {
  final Map<String, dynamic>? formula;

  const FormulaAddPage({super.key, this.formula});

  @override
  _FormulaAddPageState createState() => _FormulaAddPageState();
}

class _FormulaAddPageState extends State<FormulaAddPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final formulaAddProvider =
        Provider.of<FormulaAddProvider>(context, listen: false);
    formulaAddProvider.loadCategories();
    if (widget.formula != null) {
      formulaAddProvider.formulaName.text = widget.formula!['name'];
      formulaAddProvider.notes.text = widget.formula!['notes'];
      formulaAddProvider.formulaType.text = widget.formula!['type'];
      formulaAddProvider.creationDate.text =
          DateTime.parse(widget.formula!['creation_date']) as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final formulaAddProvider = Provider.of<FormulaAddProvider>(context, listen: false);
    return Consumer<FormulaAddProvider>(
        builder: (context, formulaAddProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add Formula'), // Optional: Add an AppBar
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap TextFormFields in Expanded or Flexible to ensure they get enough space
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Formula Name'),
                  controller: formulaAddProvider.formulaName,
                  // onChanged: (value) => formulaName = value,
                  validator: (value) =>
                      value != null && value.isNotEmpty ? null : 'Required',
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Formula Notes'),
                  // initialValue: notes,
                  controller: formulaAddProvider.notes,
                  // onChanged: (value) => notes = value,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    // DropdownButtonFormField inside a SizedBox to provide bounded width
                    Expanded(
                        child: DropdownButtonFormField<String>(
                      value: formulaAddProvider.selectedCategory,
                      items: formulaAddProvider.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['category_id'],
                          child: Text(
                            category['description'],
                            overflow: TextOverflow.ellipsis,
                            textScaler: TextScaler.linear(.7),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        formulaAddProvider.updateSelectedCategory(newValue);
                        formulaAddProvider.printCategory();
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(),
                      ),
                    )
                        // },
                        // ),
                        // ),
                        )
                  ],
                ),
                const SizedBox(height: 50.0),

                // Read-only creation date
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Created on: ${formulaAddProvider.creationDate.text.isEmpty ? DateTime.now() : formulaAddProvider.creationDate.text}',
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     ElevatedButton(
                //       onPressed: () async {
                //         if (_formKey.currentState?.validate() == true) {
                //           final formula = {
                //             'name': formulaAddProvider.formulaName,
                //             'creation_date': DateTime.now().toIso8601String(),
                //             'notes': formulaAddProvider.notes,
                //             'type': formulaAddProvider.formulaType,
                //           };

                //           // Debug: Check what is being saved
                //           print("Saving formula: $formula");

                //           // Access the provider and call the addFormula method
                //           await formulaAddProvider.addFormula(formula);

                //           // Debug: Confirm formula was saved
                //           print("Formula saved!");

                //           // Navigate back to the previous screen after saving
                //           Navigator.pop(context);
                //         }
                //       },
                //       child: const Text('Save Formula'),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
            height: 70, // Adjust height
            width: 140, // Adjust width
            child: FloatingActionButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() == true) {
                  final formula = {
                    'name': formulaAddProvider.formulaName.text,
                    'creation_date': DateTime.now().toIso8601String(),
                    'notes': formulaAddProvider.notes.text,
                    'type': formulaAddProvider.formulaType.text,
                  };

                  // Debug: Check what is being saved
                  print("Saving formula: $formula");

                  // Access the provider and call the addFormula method
                  await formulaAddProvider.addFormula(formula);

                  // Debug: Confirm formula was saved
                  print("Formula saved!");

                  // Navigate back to the previous screen after saving
                  Navigator.pop(context);
                }
                // if (mounted) {
                //   final formulaListProvider =
                //       Provider.of<FormulaListProvider>(context, listen: false);
                //   formulaListProvider.fetchFormulas();
                // }
              },
              child: const Text('Save Formula'),
              tooltip: 'Save Formula',
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }
}
