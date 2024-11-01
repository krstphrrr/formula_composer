import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FormulaIngredientListItem extends StatelessWidget {
  final String title;
  final TextEditingController amountController;
  final TextEditingController dilutionController;
  final String relativeAmountText;
  final VoidCallback onDeletePressed;
  final void Function(dynamic) onChangedAmount;
  final void Function(dynamic) onChangedDilution;
  final FocusNode? amountFocusNode;
  final FocusNode? dilutionFocusNode;

  const FormulaIngredientListItem({
    super.key,
    required this.title,
    required this.amountController,
    required this.dilutionController,
    required this.relativeAmountText,
    required this.onDeletePressed,
    required this.onChangedAmount,
    required this.onChangedDilution,
   this.amountFocusNode,
   this.dilutionFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDeletePressed(),
            icon: Icons.delete,
            foregroundColor: Colors.black,
            backgroundColor: Colors.red,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            SizedBox(width: 20),
            Flexible(
              flex: 3,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 100), // Adjust max width as needed
                child: FittedBox(
                  fit: BoxFit
                      .scaleDown, // Scales text down to fit within available space
                  alignment: Alignment.centerLeft, // Align text to the left
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10), // Add some spacing
            Expanded(
              // flex: 2,
              child: TextField(
                focusNode: amountFocusNode,
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Amount (g)',
                  border: InputBorder.none,
                ),
                
                onChanged: (value) {
                  onChangedAmount;
                },
              ),
            ),
            SizedBox(width: 5), // Add some spacing
            Expanded(
              // flex: 2,
              child: TextField(
                focusNode: dilutionFocusNode,
                controller: dilutionController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Dilution (0-1)',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                 onChangedDilution;
                },
              ),
            ),
            SizedBox(width: 30), // Add some spacing
            Flexible(
              flex: 3,
              child: Text(
                'Rel: $relativeAmountText%',
                // overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
