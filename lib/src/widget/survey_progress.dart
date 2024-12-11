import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survey_kit/src/presenter/survey_presenter.dart';
import 'package:survey_kit/src/presenter/survey_state.dart';
import 'package:survey_kit/src/widget/survey_progress_configuration.dart';
import 'package:survey_kit/src/theme_extensions.dart';

class SurveyProgress extends StatefulWidget {
  const SurveyProgress({Key? key}) : super(key: key);

  @override
  State<SurveyProgress> createState() => _SurveyProgressState();
}

class _SurveyProgressState extends State<SurveyProgress> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  static double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressbarConfiguration = context.read<SurveyProgressConfiguration>();

    return BlocBuilder<SurveyPresenter, SurveyState>(builder: (context, state) {
      if (state is PresentingSurveyState) {
        final totalSteps = state.steps.length;
        final childFlowSteps = state.steps.where((step) => step.stepIdentifier.id.contains('cq')).length;
        final adultFlowSteps = totalSteps - childFlowSteps - state.steps.where((step) => step.stepIdentifier.id.contains('a')).length;

        final isChildFlow = state.questionResults.any((result) => result.id?.id.contains('cq') ?? false);
        final totalFlowSteps = isChildFlow ? childFlowSteps : adultFlowSteps;

        final targetProgress = (state.currentStepIndex + 1) / totalFlowSteps;

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
                      color: context.card,
                    ),
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(
                        begin: _currentProgress,
                        end: targetProgress,
                      ),
                      onEnd: () {
                        _currentProgress = targetProgress;
                      },
                      builder: (context, double value, child) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              width: constraints.maxWidth * value,
                              height: progressbarConfiguration.height,
                              decoration: BoxDecoration(
                                gradient: context.buttonGradient,
                              ),
                            );
                          },
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
