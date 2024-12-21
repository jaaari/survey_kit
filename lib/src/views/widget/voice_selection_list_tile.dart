import 'package:flutter/material.dart';
import 'package:survey_kit/src/kuluko_theme.dart';
import 'package:survey_kit/src/views/decorations/gradient_box_border.dart';
import 'package:survey_kit/src/theme_extensions.dart';
class VoiceSelectionListTile extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool isSelected;
  final String imageURL;

  const VoiceSelectionListTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.imageURL = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.standard.value, horizontal: context.medium.value),
        child: InkWell(
          onTap: () => onTap.call(),
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 20.0,
            ).copyWith(
              top: isSelected ? 12.0 : 14.0,
              bottom: isSelected ? 12.0 : 14.0,
              left: isSelected ? 18.0 : 20.0,
              right: isSelected ? 18.0 : 20.0,
            ),
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
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              trailing: imageURL != "" ? Container(width: 100, color: Colors.transparent) : null,
              onTap: () => onTap.call(),
            ),
          ),
        ),
      ),
    );
  }
}
