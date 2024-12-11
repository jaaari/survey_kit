import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:survey_kit/src/result/question_result.dart';
import 'package:survey_kit/src/steps/step.dart' as surveystep;
import 'package:survey_kit/src/widget/survey_progress.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'package:survey_kit/src/views/decorations/gradient_box_border.dart';
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
          // Fixed title section
          Container(
            color: context.background,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left (invisible) icon
                if (step.infoText.isNotEmpty)
                  SizedBox(
                    width: context.screenWidth * 0.05,
                    child: IconButton(
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: context.background,
                        size: context.screenWidth * 0.05,
                      ),
                      onPressed: () {},
                    ),
                  ),
                
                // Title with consistent padding
                Container(
                  width: context.screenWidth * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: title,
                  ),
                ),
              
                // Right (visible) icon
                if (step.infoText.isNotEmpty)
                  SizedBox(
                    width: context.screenWidth * 0.05,
                    child: IconButton(
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: context.textPrimary,
                        size: context.screenWidth * 0.05,
                      ),
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
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      step.infoTitle,
                                      style: context.body.copyWith(
                                        color: context.textPrimary,
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
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.5, // Adjust this value as needed
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom navigation section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                SurveyProgress(),
                SizedBox(height: 16),
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
                    SizedBox(width: 16),
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
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: enabled ? 
          GradientBoxBorder(
            gradient: context.buttonGradient,
            width: 2,
          ) : 
          Border.all(
            color: context.border,
            width: 2,
          ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: enabled ? Colors.white : context.border,
        ),
        onPressed: onPressed,
        iconSize: 24,
        padding: EdgeInsets.all(18),
      ),
    );
  }
}
