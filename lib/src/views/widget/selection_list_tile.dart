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
    print('SelectionListTile is being built');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Margin
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8), // Padding
        decoration: BoxDecoration(
          // if selected, change the background color to the primary color, else use the default color
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(14.0), 
          image: imageURL != "" ? DecorationImage(
            image: NetworkImage(imageURL),
            fit: BoxFit.fitHeight,
            alignment: Alignment.centerRight,
          ) : null,
        ),
        child: ListTile(
          title: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
          // if image is not null, display a square transparent container at the end so the background image is visible (100% height and square width)
          trailing: imageURL != ""
              ? Container(
                  width: 50,
                  height: 50,
                  color: Colors.transparent,
                )
              : null,
          onTap: () => onTap.call(),
        ),
      ),
    );
  }
}
