import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:survey_kit/src/result/question_result.dart';
import 'package:survey_kit/src/steps/step.dart' as surveystep;
import 'package:survey_kit/src/widget/survey_progress.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'package:survey_kit/src/views/decorations/gradient_box_border.dart';
import 'dart:ui';

class StepView extends StatelessWidget {
  final surveystep.Step step;
  final Widget title;
  final Widget child;
  final QuestionResult Function() resultFunction;
  final bool isValid;
  final SurveyController? controller;

  const StepView({
    required this.step,
    required this.child,
    required this.title,
    required this.resultFunction,
    this.controller,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    print("StepView - build called for step ID: ${step.stepIdentifier.id}");
    final _surveyController = controller ?? context.read<SurveyController>();

    return Scaffold(
      backgroundColor: context.background,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SizedBox(height: context.extraLarge.value),
          // Title section
          Container(
            color: context.background,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: context.screenWidth * 0.8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: title,
              ),
            ),
          ),
          
          // Scrollable content with fading edges
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white,
                          Colors.white,
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [0.0, 0.05, 0.95, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: context.extraLarge.value),
                          child,
                          SizedBox(height: context.extraLarge.value),
                        ],
                      ),
                    ),
                  ),
                ),
                if (step.infoText.isNotEmpty)
                  Positioned(
                    right: context.screenWidth * 0.03,
                    bottom: 0,
                    child: IconButton(
                      icon: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return context.buttonGradient.createShader(bounds);
                        },
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: context.screenWidth * 0.06,
                        ),
                      ),
                      padding: EdgeInsets.all(12),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24.0),
                                decoration: BoxDecoration(
                                  color: context.surface,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      step.infoTitle,
                                      style: context.body.copyWith(
                                        color: context.primaryPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                        vertical: 12.0,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color: context.border,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      child: Text(
                                        step.infoText,
                                        style: context.body.copyWith(
                                          color: context.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(
                                          'Close',
                                          style: context.body.copyWith(
                                            color: context.textSecondary,
                                          ),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          // Bottom navigation section
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.extraLarge.value),
            child: Column(
              children: [
                SurveyProgress(),
                SizedBox(height: context.extraLarge.value),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      context,
                      icon: Icons.arrow_back,
                      onPressed: () {
                        _surveyController.stepBack(context: context);
                      },
                    ),
                    SizedBox(width: context.extraLarge.value),
                    _buildIconButton(
                      context,
                      icon: Icons.arrow_forward,
                      onPressed: isValid || step.isOptional
                          ? () {
                              if (FocusScope.of(context).hasFocus) {
                                FocusScope.of(context).unfocus();
                                Future.delayed(Duration(milliseconds: 50), () {
                                  if (context.mounted) {
                                    _surveyController.nextStep(context, resultFunction);
                                  }
                                });
                              } else {
                                _surveyController.nextStep(context, resultFunction);
                              }
                            }
                          : null,
                      enabled: isValid || step.isOptional,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon, required VoidCallback? onPressed, bool enabled = true}) {
    return Container(
      width: context.screenWidth * 0.15,
      height: context.screenWidth * 0.15,
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(context.extraLarge.value),
        border: enabled ? 
          GradientBoxBorder(
            gradient: context.buttonGradient,
            width: context.extraSmall.value,
          ) : 
          Border.all(
            color: context.border,
            width: context.extraSmall.value,
          ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: enabled ? Colors.white : context.border,
        ),
        onPressed: onPressed,
        iconSize: context.screenWidth * 0.065,
        padding: EdgeInsets.all(context.extraLarge.value),
      ),
    );
  }
}