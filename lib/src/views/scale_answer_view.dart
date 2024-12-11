import 'package:flutter/material.dart';
import 'package:survey_kit/src/answer_format/scale_answer_format.dart';
import 'package:survey_kit/src/result/question/scale_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'package:survey_kit/src/views/decorations/gradient_box_border.dart';

class ScaleAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final ScaleQuestionResult? result;

  const ScaleAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _ScaleAnswerViewState createState() => _ScaleAnswerViewState();
}

class _ScaleAnswerViewState extends State<ScaleAnswerView> {
  late final DateTime _startDate;
  late final ScaleAnswerFormat _scaleAnswerFormat;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _scaleAnswerFormat = widget.questionStep.answerFormat as ScaleAnswerFormat;
    _selectedIndex = widget.result?.result?.toInt() ?? _scaleAnswerFormat.defaultValue.toInt();
    _startDate = DateTime.now();
    _onAnswerChanged(_selectedIndex.toDouble());
  }

  void _onAnswerChanged(double value) {
    if (widget.questionStep.relatedParameter == "") {
      return;
    }
    Map<String, dynamic> _resultMap = {
      widget.questionStep.relatedParameter: value,
    };
    GlobalStateManager().updateData(_resultMap);
  }

  Widget _buildScaleBox(int index) {
    bool isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _onAnswerChanged(index.toDouble());
      },
      child: Container(
        width: 45,
        height: 45,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? 
            GradientBoxBorder(
              gradient: context.buttonGradient,
              width: 2,
            ) : Border.all(
              color: context.border,
              width: 2,
            ),
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: context.body.copyWith(
              color: isSelected ? context.textPrimary : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => ScaleQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _selectedIndex.toString(),
        result: _selectedIndex.toDouble(),
      ),
      title: widget.questionStep.title.isNotEmpty
          ? Text(
              widget.questionStep.title,
              style: context.body.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            )
          : widget.questionStep.content,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.questionStep.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0, left: 14.0, right: 14.0),
                child: Text(
                  widget.questionStep.text,
                  style: context.body.copyWith(color: context.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) => _buildScaleBox(index)),
            ),
            SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 7 * 45 + 6 * 8, // 7 buttons * width + 6 gaps * margin
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Simple',
                    style: context.caption.copyWith(color: context.textSecondary),
                  ),
                  Text(
                    'Casual',
                    style: context.caption.copyWith(color: context.textSecondary),
                  ),
                  Text(
                    'Complex',
                    style: context.caption.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
