import 'package:flutter/material.dart';

class IngredientListPage extends StatefulWidget {
  const IngredientListPage({ Key? key }) : super(key: key);

  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Ingredient list"),
      ),
    );
  }
}