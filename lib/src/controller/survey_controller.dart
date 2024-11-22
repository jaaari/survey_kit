import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survey_kit/src/presenter/survey_event.dart';
import 'package:survey_kit/src/presenter/survey_presenter.dart';
import 'package:survey_kit/src/result/question_result.dart';


class SurveyController {
  final bool Function(
    BuildContext context,
    QuestionResult Function() resultFunction,
  )? onNextStep;

  final bool Function(
    BuildContext context,
    QuestionResult Function()? resultFunction,
  )? onStepBack;

  final bool Function(
    BuildContext context,
    QuestionResult Function()? resultFunction,
  )? onCloseSurvey;

  SurveyController({
    this.onNextStep,
    this.onStepBack,
    this.onCloseSurvey,
  });

  void nextStep(
    BuildContext context,
    QuestionResult Function() resultFunction,
  ) {
    print("SurveyController - nextStep called");
    if (onNextStep != null) {
      print("SurveyController - onNextStep callback exists");
      if (!onNextStep!(context, resultFunction)) return;
    }

    final currentResult = resultFunction.call();
    print("SurveyController - Current result: $currentResult");

    BlocProvider.of<SurveyPresenter>(context).add(
      NextStep(currentResult),
    );
  }

  void stepBack({
    required BuildContext context,
    QuestionResult Function()? resultFunction,
  }) {
    if (onStepBack != null) {
      if (!onStepBack!(context, resultFunction)) return;
    }
    BlocProvider.of<SurveyPresenter>(context).add(
      StepBack(
        resultFunction != null ? resultFunction.call() : null,
      ),
    );
  }

  void closeSurvey(
    BuildContext context, {
    QuestionResult Function()? resultFunction,
  }) {
    if (onCloseSurvey != null) {
      if (!onCloseSurvey!(context, resultFunction)) return;
    }
    BlocProvider.of<SurveyPresenter>(context).add(
      CloseSurvey(
        resultFunction != null ? resultFunction.call() : null,
      ),
    );
  }
}
