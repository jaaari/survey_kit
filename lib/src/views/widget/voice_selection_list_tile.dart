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
    final width = context.screenWidth;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 100.0,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Row(
              children: [
                if (imageURL.isNotEmpty)
                  Container(
                    width: width * 0.25,
                    height: width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14.0),
                        bottomLeft: Radius.circular(14.0),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(imageURL),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: InkWell(
                    onTap: () => onTap.call(),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14.0),
                      bottomRight: Radius.circular(14.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 20),
                      child: Text(
                        text,
                        textAlign: TextAlign.left,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.body.copyWith(color: isSelected ? context.textPrimary : context.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  border: GradientBoxBorder(
                    gradient: context.buttonGradient,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
