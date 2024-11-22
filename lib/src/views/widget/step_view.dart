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
    print("StepView - build called for step ID: ${step.stepIdentifier.id}");
    final _surveyController = controller ?? context.read<SurveyController>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Scrollable content area
              // Scrollable content area
Expanded(
  child: SingleChildScrollView(
    child: Center( // Centers the content within the available space
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight * 0.7,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Ensures center alignment within the column
          children: [
            // Title section (with optional info icon)
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
                            return Dialog(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Information',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(step.infoText),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
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
            // Survey question content
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

              // Fixed progress bar and navigation buttons at the bottom
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
                                    // Add a small delay to ensure unfocus completes
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
