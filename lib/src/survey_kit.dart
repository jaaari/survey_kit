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
import 'package:survey_kit/src/widget/survey_progress_with_animation.dart';

class SurveyKit extends StatefulWidget {
  final Task task;
  final ThemeData? themeData;
  final Function(SurveyResult) onResult;
  final SurveyController? surveyController;
  final Widget Function(AppBarConfiguration appBarConfiguration)? appBar;
  final Map<String, String>? localizations;
  final double? height;

  const SurveyKit({
    required this.task,
    required this.onResult,
    this.themeData,
    this.surveyController,
    this.appBar,
    this.localizations,
    this.height,
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
          Provider<Map<String, String>?>.value(value: widget.localizations),
          // Ensure SurveyProgressConfiguration is provided
          Provider<SurveyProgressConfiguration>(
            create: (_) => SurveyProgressConfiguration(), // Customize as needed
          ),
        ],
        child: BlocProvider(
          create: (BuildContext context) => SurveyPresenter(
            taskNavigator: _taskNavigator,
            onResult: widget.onResult,
          ),
          child: SurveyPage(
            length: widget.task.steps.length,
            onResult: widget.onResult,
            height: widget.height,
          ),
        ),
      ),
    );
  }
}
class SurveyPage extends StatefulWidget {
  final int length;
  final Function(SurveyResult) onResult;
  final double? height;
  final SurveyController? controller;


  const SurveyPage({
    required this.length,
    required this.onResult,
    this.height,
    this.controller,
  });

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _surveyController = controller ?? context.read<SurveyController>();

    return BlocConsumer<SurveyPresenter, SurveyState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) async {
        if (state is SurveyResultState) {
          widget.onResult.call(state.result);
        }
      },
      builder: (BuildContext context, SurveyState state) {
        if (state is PresentingSurveyState) {
          return Scaffold(
            backgroundColor: Colors.red,
            body: Center(
              child: SizedBox(
                height: widget.height ?? MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    // Survey content with TabBarView (displays the questions)
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: NeverScrollableScrollPhysics(),
                        children: state.steps.map((e) {
                          return _SurveyView(
                            id: e.stepIdentifier.id,
                            createView: () => e.createView(
                              questionResult: state.questionResults.firstWhereOrNull(
                                (element) => element.id == e.stepIdentifier,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Attach progress bar and buttons below the TabBarView
                    Column(
  children: [
    // Background container for progress bar and buttons
    Container(
      color: Theme.of(context).colorScheme.surface, // Set your desired background color here
      padding: EdgeInsets.symmetric(vertical: 16.0), // Optional: Add some padding
      child: Column(
        children: [
          // Rounded and narrower progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Adjust horizontal padding for narrowing
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0), // Makes the progress bar rounded
              child: SurveyProgressWithAnimation(
        currentStep: _tabController.index + 1,  // Current step
        totalSteps: widget.length,              // Total number of steps
      ),
            ),
          ),

          SizedBox(height: 16), // Space between the progress bar and buttons

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(
                context,
                icon: Icons.arrow_back,
                onPressed: _tabController.index > 0
                    ? () {
                        setState(() {
                          _tabController.animateTo(_tabController.index - 1);
                        });
                      }
                    : null,
              ),
              SizedBox(width: 16), // Space between the buttons
              _buildIconButton(
                context,
                icon: Icons.arrow_forward,
                onPressed: _tabController.index < state.steps.length - 1
                    ? () {
                        setState(() {
                          _tabController.animateTo(_tabController.index + 1);
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    ),
  ],
)

                  ],
                ),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
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


// Define _SurveyView as before
class _SurveyView extends StatelessWidget {
  final String id;
  final Widget Function() createView;
  final double? height; // Nullable height parameter

  const _SurveyView({
    required this.id,
    required this.createView,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>(id),
      child: Center(
        child: height != null
            ? SizedBox(
                height: height,
                child: createView(),
              )
            : createView(),
      ),
    );
  }
}
