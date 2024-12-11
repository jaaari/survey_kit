import 'package:flutter/material.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'package:survey_kit/src/views/decorations/gradient_box_border.dart';

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
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: InkWell(
            onTap: () => onTap.call(),
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
              constraints: BoxConstraints(
                minHeight: 100.0,
                maxHeight: imageURL != "" ? 100.0 : double.infinity,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(14.0),
                border: isSelected ? 
                  GradientBoxBorder(
                    gradient: context.buttonGradient,
                    width: 2,
                  ) : null,
                image: imageURL != "" ? DecorationImage(
                  image: NetworkImage(imageURL),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerRight,
                ) : null,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  text,
                  style: context.body.copyWith(
                    color: Color(isSelected ? context.textPrimary.value : context.textSecondary.value),
                  ),
                  overflow: imageURL != "" ? TextOverflow.ellipsis : null,
                  textAlign: TextAlign.center,
                ),
                trailing: imageURL != "" ? Container(width: 100, color: Colors.transparent) : null,
                onTap: () => onTap.call(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
