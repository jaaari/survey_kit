import 'package:flutter/material.dart';
import 'package:survey_kit/src/answer_format/boolean_answer_format.dart';
import 'package:survey_kit/src/result/question/boolean_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/selection_list_tile.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';

class BooleanAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final BooleanQuestionResult? result;

  const BooleanAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _BooleanAnswerViewState createState() => _BooleanAnswerViewState();
}

class _BooleanAnswerViewState extends State<BooleanAnswerView> {
  late final BooleanAnswerFormat _answerFormat;
  late final DateTime _startDate;
  BooleanResult? _result;

  @override
  void initState() {
    super.initState();
    _answerFormat = widget.questionStep.answerFormat as BooleanAnswerFormat;
    _result = widget.result?.result ??
        _answerFormat.defaultValue ??
        _answerFormat.result;
    _startDate = DateTime.now();
    _onAnswerChanged(_result);
  }

  void _onAnswerChanged(BooleanResult? result) {
    print("tapped a boolean answer");
    Map<String, dynamic> _resultMap = {
      widget.questionStep.relatedParameter: result == BooleanResult.POSITIVE
    };
    GlobalStateManager().updateData(_resultMap);
    Map<String, dynamic> _allData = GlobalStateManager().getAllData();
    print("relatedParameter: ${widget.questionStep.relatedParameter}");
    print("Global state: $_allData");
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => BooleanQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _result == BooleanResult.POSITIVE
            ? "POSITIVE"
            : _result == BooleanResult.NEGATIVE
                ? "NEGATIVE"
                : '',
        result: _result,
      ),
      title: widget.questionStep.title.isNotEmpty
          ? Text(
              widget.questionStep.title,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            )
          : widget.questionStep.content,
      isValid: widget.questionStep.isOptional ||
          (_result != BooleanResult.NONE && _result != null),
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
              Divider(
                color: Colors.grey,
              ),
              SelectionListTile(
                text: _answerFormat.positiveAnswer,
                onTap: () {
                  if (_result == BooleanResult.POSITIVE) {
                    _result = null;
                  } else {
                    _result = BooleanResult.POSITIVE;
                  }
                  setState(() {});
                  _onAnswerChanged(_result);
                },
                isSelected: _result == BooleanResult.POSITIVE,
              ),
              SelectionListTile(
                text: _answerFormat.negativeAnswer,
                onTap: () {
                  if (_result == BooleanResult.NEGATIVE) {
                    _result = null;
                  } else {
                    _result = BooleanResult.NEGATIVE;
                  }
                  setState(() {});
                  _onAnswerChanged(_result);
                },
                isSelected: _result == BooleanResult.NEGATIVE,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
