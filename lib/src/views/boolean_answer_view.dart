import 'package:flutter/material.dart';
import 'package:survey_kit/src/answer_format/boolean_answer_format.dart';
import 'package:survey_kit/src/result/question/boolean_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/selection_list_tile.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';

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
    _result = null; // Start with no selection
    _startDate = DateTime.now();
  }

  void _onAnswerChanged(BooleanResult? result) {
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

    // Proceed to next step
    final resultFunction = () => BooleanQuestionResult(
          id: widget.questionStep.stepIdentifier,
          startDate: _startDate,
          endDate: DateTime.now(),
          valueIdentifier:
              _result == BooleanResult.POSITIVE ? "POSITIVE" : "NEGATIVE",
          result: _result,
        );
    Provider.of<SurveyController>(context, listen: false)
        .nextStep(context, resultFunction);
  }

  @override
  Widget build(BuildContext context) {
    print("BooleanAnswerView: Building");
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
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  fontWeight:
                      Theme.of(context).textTheme.titleMedium?.fontWeight,
                  color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.center)
          : widget.questionStep.content,
      isValid: widget.questionStep.isOptional ||
          _result != null, // Validation requires a choice
      child: Column(
        children: [
          // if (widget.questionStep.title.isNotEmpty) display text
          if (widget.questionStep.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                widget.questionStep.text,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          Column(
            children: [
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
        ],
      ),
    );
  }
}
