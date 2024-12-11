import 'package:flutter/material.dart';
import 'package:survey_kit/src/answer_format/boolean_answer_format.dart';
import 'package:survey_kit/src/result/question/boolean_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/selection_list_tile.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:survey_kit/src/theme_extensions.dart';

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
    _result = null;
    _startDate = DateTime.now();
  }

  void _onAnswerChanged(BooleanResult result) {
    print("tapped a boolean answer");
    setState(() {
      _result = result;
    });

    if (widget.questionStep.relatedParameter != "") {
      Map<String, dynamic> _resultMap = {
        widget.questionStep.relatedParameter: result == BooleanResult.POSITIVE
      };
      GlobalStateManager().updateData(_resultMap);
      print("Global state updated: ${GlobalStateManager().getAllData()}");
    }
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
          ? Text(widget.questionStep.title,
              style: context.body.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center)
          : widget.questionStep.content,
      isValid: widget.questionStep.isOptional || _result != null,
      child: Column(
        children: [
          if (widget.questionStep.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(context.standard.value),
              child: Text(
                widget.questionStep.text,
                style: context.body.copyWith(color: context.textPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          SelectionListTile(
            text: _answerFormat.positiveAnswer,
            onTap: () => _onAnswerChanged(BooleanResult.POSITIVE),
            isSelected: _result == BooleanResult.POSITIVE,
          ),
          SelectionListTile(
            text: _answerFormat.negativeAnswer,
            onTap: () => _onAnswerChanged(BooleanResult.NEGATIVE),
            isSelected: _result == BooleanResult.NEGATIVE,
          ),
        ],
      ),
    );
  }
}
