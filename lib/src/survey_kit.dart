import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/configuration/app_bar_configuration.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:survey_kit/src/navigator/navigable_task_navigator.dart';
import 'package:survey_kit/src/navigator/ordered_task_navigator.dart';
import 'package:survey_kit/src/navigator/task_navigator.dart';
import 'package:survey_kit/src/presenter/survey_presenter.dart';
import 'package:survey_kit/src/presenter/survey_state.dart';
import 'package:survey_kit/src/result/survey/survey_result.dart';
import 'package:survey_kit/src/task/navigable_task.dart';
import 'package:survey_kit/src/task/ordered_task.dart';
import 'package:survey_kit/src/task/task.dart';
import 'package:survey_kit/src/views/widget/survey_app_bar.dart';
import 'package:survey_kit/src/widget/survey_progress_configuration.dart';

class SurveyKit extends StatefulWidget {
  /// [Task] for the configuraton of the survey
  final Task task;

  /// [ThemeData] to override the Theme of the subtree
  final ThemeData? themeData;

  /// Function which is called after the results are collected
  final Function(SurveyResult) onResult;

  /// [SurveyController] to override the navigation methods
  /// onNextStep, onBackStep, onCloseSurvey
  final SurveyController? surveyController;

  /// The appbar that is shown at the top
  final Widget Function(AppBarConfiguration appBarConfiguration)? appBar;

  /// If the progressbar shoud be show in the appbar
  final bool? showProgress;

  // Changes the styling of the progressbar in the appbar
  final SurveyProgressConfiguration? surveyProgressbarConfiguration;

  final Map<String, String>? localizations;

  // Optional height parameter
  final double? height;

  const SurveyKit({
    required this.task,
    required this.onResult,
    this.themeData,
    this.surveyController,
    this.appBar,
    this.showProgress,
    this.surveyProgressbarConfiguration,
    this.localizations,
    this.height, // add height here
  });
@override
  _SurveyKitState createState() => _SurveyKitState();
}

class _SurveyKitState extends State<SurveyKit> {
  late TaskNavigator _taskNavigator;

  @override
  void initState() {
    super.initState();
    _taskNavigator = _createTaskNavigator();
  }

  TaskNavigator _createTaskNavigator() {
    switch (widget.task.runtimeType) {
      case OrderedTask:
        return OrderedTaskNavigator(widget.task);
      case NavigableTask:
        return NavigableTaskNavigator(widget.task);
      default:
        return OrderedTaskNavigator(widget.task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData ?? Theme.of(context),
      child: MultiProvider(
        providers: [
          Provider<TaskNavigator>.value(value: _taskNavigator),
          Provider<SurveyController>.value(
              value: widget.surveyController ?? SurveyController()),
          Provider<bool>.value(value: widget.showProgress ?? true),
          Provider<SurveyProgressConfiguration>.value(
            value: widget.surveyProgressbarConfiguration ??
                SurveyProgressConfiguration(),
          ),
          Provider<Map<String, String>?>.value(value: widget.localizations),
        ],
        child: BlocProvider(
          create: (BuildContext context) => SurveyPresenter(
            taskNavigator: _taskNavigator,
            onResult: widget.onResult,
          ),
          child: SurveyPage(
            length: widget.task.steps.length,
            onResult: widget.onResult,
            appBar: widget.appBar,
            height: widget.height, // pass the height to SurveyPage
          ),
        ),
      ),
    );
  }
}

class SurveyPage extends StatefulWidget {
  final int length;
  final Widget Function(AppBarConfiguration appBarConfiguration)? appBar;
  final Function(SurveyResult) onResult;
  
  // Optional height parameter
  final double? height;

  const SurveyPage({
    required this.length,
    required this.onResult,
    this.appBar,
    this.height, // add height here
  });

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SurveyPresenter, SurveyState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) async {
        if (state is SurveyResultState) {
          widget.onResult.call(state.result);
        }
        // No need for tabController.animateTo here, we'll handle transition with AnimatedSwitcher
      },
      builder: (BuildContext context, SurveyState state) {
        if (state is PresentingSurveyState) {
          return Scaffold(
            backgroundColor: Colors.red,
            appBar: null,
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 0), // Duration of the fade transition
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Swipe transition
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _SurveyView(
                 // Helps AnimatedSwitcher recognize changes
                id: state.steps[state.currentStepIndex].stepIdentifier.id,
                createView: () => state.steps[state.currentStepIndex].createView(
                  questionResult: state.questionResults.firstWhereOrNull(
                    (element) => element.id == state.steps[state.currentStepIndex].stepIdentifier,
                  ),
                ),
                height: widget.height, // pass the height to _SurveyView
              ),
            ),
          );
        } else if (state is SurveyResultState && state.currentStep != null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}


class _SurveyView extends StatelessWidget {
  const _SurveyView({
    required this.id,
    required this.createView,
    this.height, // Optional height parameter
  });

  final String id;
  final Widget Function() createView;
  final double? height; // Nullable height

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>(
        id,
      ),
      child: Center(
        child: height != null
            ? SizedBox(
                height: height, // Use the provided height
                child: createView(),
              )
            : createView(), // Default behavior when no height is provided
      ),
    );
  }
}


