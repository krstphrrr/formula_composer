import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FormulaListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  final VoidCallback? onTap; // Add onTap callback
  // final String trailing;
// const FormulaListItem({ Key? key }) : super(key: key);
  const FormulaListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.onTap
  });

  @override
  Widget build(BuildContext context){
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(), 
        children: [
          SlidableAction(
            onPressed: onEditPressed,
            icon: Icons.edit,
            ),
           SlidableAction(
            onPressed: onDeletePressed,
            icon: Icons.delete,
            foregroundColor: Colors.black,
            backgroundColor: Colors.red,
            )
        ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ));
  }
}