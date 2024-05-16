import 'package:flutter/material.dart';
import 'package:survey_kit/src/kuluko_theme.dart';

class SelectionListTile extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool isSelected;
  final String? image;  // Optional parameter for image URL

  const SelectionListTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.image,  // Accepting an image URL
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: ListTile(
            tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            leading: image != null
                ? Image(
                    image: NetworkImage(image!))
                : null,
            title: Text(
              text,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.headlineSmall?.color,
                  ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check,
                    size: 32,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black,
                  )
                : Container(
                    width: 32,
                    height: 32,
                  ),
            onTap: () => onTap.call(),
          ),
        ),
        Divider(
          color: Colors.grey,
        ),
      ],
    );
  }
}
