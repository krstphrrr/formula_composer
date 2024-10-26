import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  final VoidCallback? onTap; 
  final ImageProvider? centerImage; // Image for the center column

  const CustomListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.onTap,
    this.centerImage, // Accept image as an argument
  });

  @override
  Widget build(BuildContext context) {
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
                  : const SizedBox.shrink(), // Placeholder if no image is provided
            ),
            // Right column for additional actions or empty space
            Expanded(
              flex: 1,
              child: Container(), // Can be left empty or used for icons
            ),
          ],
        ),
      ),
    );
  }
}