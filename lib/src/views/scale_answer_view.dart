import 'package:flutter/material.dart';
import 'package:survey_kit/src/answer_format/scale_answer_format.dart';
import 'package:survey_kit/src/result/question/scale_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';

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
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _scaleAnswerFormat = widget.questionStep.answerFormat as ScaleAnswerFormat;
    _sliderValue = widget.result?.result ?? _scaleAnswerFormat.defaultValue;
    _startDate = DateTime.now();
    _onAnswerChanged(_sliderValue);
  }

  void _onAnswerChanged(double value) {
    print("tapped a scale answer");
    if (widget.questionStep.relatedParameter == "") {
      return;
    }
    Map<String, dynamic> _resultMap = {
      widget.questionStep.relatedParameter: value,
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
      resultFunction: () => ScaleQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _sliderValue.toString(),
        result: _sliderValue,
      ),
      title: widget.questionStep.title.isNotEmpty
          ? Text(
              widget.questionStep.title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            )
          : widget.questionStep.content,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 32.0, left: 14.0, right: 14.0),
            child: Text(
              widget.questionStep.text,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_scaleAnswerFormat.showValue)
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      _sliderValue.toInt().toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _scaleAnswerFormat.minimumValueDescription,
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(
                            width: 32.0,
                          ),
                          Expanded(
                            child: Text(
                              _scaleAnswerFormat.maximumValueDescription,
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Slider.adaptive(
                      value: _sliderValue,
                      onChanged: (double value) {
                        setState(() {
                          _sliderValue = value;
                        });
                        _onAnswerChanged(_sliderValue);
                      },
                      min: _scaleAnswerFormat.minimumValue,
                      max: _scaleAnswerFormat.maximumValue,
                      activeColor: Theme.of(context).primaryColor,
                      divisions: (_scaleAnswerFormat.maximumValue -
                              _scaleAnswerFormat.minimumValue) ~/
                          _scaleAnswerFormat.step,
                      label: _sliderValue.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
