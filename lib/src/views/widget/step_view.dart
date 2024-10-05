import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:survey_kit/src/result/question_result.dart';
import 'package:survey_kit/src/steps/step.dart' as surveystep;
import 'package:survey_kit/src/widget/survey_progress.dart';

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
    final _surveyController = controller ?? context.read<SurveyController>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Center( // Center content vertically
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight * 0.6, // Ensure it can grow
                        
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title and optional info icon
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    child: title,
                                  ),
                                ),
                                if (step.infoText.isNotEmpty)
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: IconButton(
                                      icon: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Information'),
                                              content: Text(step.infoText),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            // Content section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Fixed progress bar and buttons at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    SurveyProgress(), // Progress bar stays fixed at the bottom
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          context,
                          icon: Icons.arrow_upward,
                          onPressed: () {
                            _surveyController.stepBack(context: context);
                          },
                        ),
                        SizedBox(width: 16),
                        _buildIconButton(
                          context,
                          icon: Icons.arrow_downward,
                          onPressed: isValid || step.isOptional
                              ? () {
                                  if (FocusScope.of(context).hasFocus) {
                                    FocusScope.of(context).unfocus();
                                  }
                                  _surveyController.nextStep(context, resultFunction);
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
          );
        },
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon, required VoidCallback? onPressed, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).colorScheme.primary,
        disabledColor: Colors.grey.withOpacity(0.5),
        iconSize: 24,
        padding: EdgeInsets.all(18),
      ),
    );
  }
}
