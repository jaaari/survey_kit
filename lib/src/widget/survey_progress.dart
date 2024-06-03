import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survey_kit/src/presenter/survey_presenter.dart';
import 'package:survey_kit/src/presenter/survey_state.dart';
import 'package:survey_kit/src/widget/survey_progress_configuration.dart';

class SurveyProgress extends StatefulWidget {
  const SurveyProgress({Key? key}) : super(key: key);

  @override
  State<SurveyProgress> createState() => _SurveyProgressState();
}

class _SurveyProgressState extends State<SurveyProgress> {
  @override
  Widget build(BuildContext context) {
    final progressbarConfiguration = context.read<SurveyProgressConfiguration>();

    return BlocBuilder<SurveyPresenter, SurveyState>(builder: (context, state) {
      if (state is PresentingSurveyState) {
        final totalSteps = state.steps.length;
        final childFlowSteps = state.steps.where((step) => step.stepIdentifier.id.contains('cq')).length;
        final adultFlowSteps = totalSteps - childFlowSteps - state.steps.where((step) => step.stepIdentifier.id.contains('a')).length;

        final childFlowResults = state.questionResults.where((result) => result.id?.id.contains('cq') ?? false).length;
        final adultFlowResults = state.questionResults.where((result) => result.id?.id.contains('cq') == false && result.id?.id.contains('a') == false).length;

        final isChildFlow = state.questionResults.any((result) => result.id?.id.contains('cq') ?? false);
        final completedSteps = isChildFlow ? childFlowResults : adultFlowResults;
        final totalFlowSteps = isChildFlow ? childFlowSteps : adultFlowSteps;

        return Padding(
          padding: progressbarConfiguration.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (progressbarConfiguration.showLabel && progressbarConfiguration.label != null)
                progressbarConfiguration.label!(
                    state.currentStepIndex.toString(), state.stepCount.toString()),
              ClipRRect(
                borderRadius: progressbarConfiguration.borderRadius ?? BorderRadius.circular(14.0),
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: progressbarConfiguration.height,
                      color: progressbarConfiguration.progressbarColor,
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final progressWidth = (completedSteps + 1) / totalFlowSteps * constraints.maxWidth;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear,
                          width: progressWidth,
                          height: progressbarConfiguration.height,
                          color: progressbarConfiguration.valueProgressbarColor ?? Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox.shrink();
    });
  }
}
