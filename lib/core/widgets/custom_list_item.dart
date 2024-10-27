import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  final VoidCallback? onTap;
  final ImageProvider? centerImage;
  final Color? categoryColor;

  const CustomListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.onTap,
    this.centerImage,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
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
              ),
            ],
          ),
          child: ListTile(
            onTap: onTap,
            title: Row(
              children: [
                // Left column for title and subtitle
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Center column for the image
                Expanded(
                  flex: 2,
                  child: centerImage != null
                      ? Image(
                          image: centerImage!,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fit: BoxFit.fitHeight,
                          height: 34,
                          width: 34,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        // Colored line below the ListTile as a divider
        if (categoryColor != null)
          Container(
            height: 3, // Thickness of the divider line
            color: categoryColor, // Divider color
          ),
      ],
    );
  }
}
