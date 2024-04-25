import 'package:flutter/material.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';

class SingleChoiceAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final SingleChoiceQuestionResult? result;

  const SingleChoiceAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _SingleChoiceAnswerViewState createState() => _SingleChoiceAnswerViewState();
}

class _SingleChoiceAnswerViewState extends State<SingleChoiceAnswerView> {
  late final DateTime _startDate;
  late final SingleChoiceAnswerFormat _singleChoiceAnswerFormat;
  TextChoice? _selectedChoice;
  List<TextChoice> _choices = [];

  @override
  void initState() {
    super.initState();
    _singleChoiceAnswerFormat = widget.questionStep.answerFormat as SingleChoiceAnswerFormat;
    _selectedChoice = widget.result?.result ?? _singleChoiceAnswerFormat.defaultSelection;
    _startDate = DateTime.now();
    print("SingleChoiceAnswerView: Selected choice: $_selectedChoice");
    _initChoices();
  }

  void _initChoices() {
    print("SingleChoiceAnswerView: Initializing choices");
    print("_singleChoiceAnswerFormat.textChoices.isNotEmpty = ${_singleChoiceAnswerFormat.textChoices.isNotEmpty}");
    if (_singleChoiceAnswerFormat.textChoices.isNotEmpty) {
      print('SingleChoiceAnswerView: Using textChoices');
      _choices = _singleChoiceAnswerFormat.textChoices;
    } else if (_singleChoiceAnswerFormat.dynamicTextChoices != "") {
      var manager = GlobalStateManager();
      var dynamicChoices = manager.getData(_singleChoiceAnswerFormat.dynamicTextChoices);
      print('SingleChoiceAnswerView: Using dynamicTextChoices: $dynamicChoices');
      if (dynamicChoices != null && dynamicChoices is List) {
        _choices = dynamicChoices.map<TextChoice>((choice) => TextChoice.fromJson(choice)).toList();
      }
    }
    // Select default choice if not set
    if (_selectedChoice == null && _choices.isNotEmpty) {
      _selectedChoice = _choices.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => SingleChoiceQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _selectedChoice?.value ?? '',
        result: _selectedChoice,
      ),
      isValid: widget.questionStep.isOptional || _selectedChoice != null,
      title: widget.questionStep.title.isNotEmpty
          ? Text(
              widget.questionStep.title,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            )
          : widget.questionStep.content,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Text(
                widget.questionStep.text,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Column(
              children: [
                Divider(color: Colors.grey),
                ..._choices.map((TextChoice tc) {
                  return SelectionListTile(
                    text: tc.text,
                    onTap: () {
                      setState(() {
                        _selectedChoice = (_selectedChoice == tc) ? null : tc;
                      });
                    },
                    isSelected: _selectedChoice == tc,
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
