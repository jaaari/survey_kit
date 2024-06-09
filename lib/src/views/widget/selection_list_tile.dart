import 'package:flutter/material.dart';
import 'package:survey_kit/src/kuluko_theme.dart';

class SelectionListTile extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool isSelected;
  final String imageURL;

  const SelectionListTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.imageURL = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Margin
      child: InkWell(
        onTap: () => onTap.call(),
        borderRadius: BorderRadius.circular(14.0), // Border radius for InkWell effect
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20), // Padding
          constraints: BoxConstraints(
            minHeight: 100.0, // Set your desired minimum height here
          ),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14.0),
            image: imageURL != "" ? DecorationImage(
              image: NetworkImage(imageURL),
              fit: BoxFit.fitHeight,
              alignment: Alignment.centerRight,
            ) : null,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero, // Remove ListTile's padding
            title: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
            ),
            trailing: imageURL != "" ? Container(width: 100, color: Colors.transparent) : null,
            onTap: () => onTap.call(),
          ),
        ),
      ),
    );
  }
}
