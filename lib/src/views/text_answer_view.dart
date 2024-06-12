import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/src/answer_format/api_call_answer_format.dart';
import 'package:survey_kit/src/answer_format/text_answer_format.dart';
import 'package:survey_kit/src/result/question/text_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/decoration/input_decoration.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';

class TextAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final TextQuestionResult? result;

  const TextAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _TextAnswerViewState createState() => _TextAnswerViewState();
}

class _TextAnswerViewState extends State<TextAnswerView> {
  late final TextAnswerFormat _textAnswerFormat;
  late final DateTime _startDate;
  late final TextEditingController _controller;
  bool _isValid = false;
  var actualHint = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _textAnswerFormat = widget.questionStep.answerFormat as TextAnswerFormat;
    _controller.text =
        widget.result?.result ?? _textAnswerFormat.defaultValue ?? '';
    _startDate = DateTime.now();
    _initHint();
    _initPlaceholder();
    if (!widget.questionStep.isOptional) {
      _checkValidation(_controller.text);
    }
  }

  void _initHint() {
    print("initHint: ${_textAnswerFormat.hint}");
    if (_textAnswerFormat.hint != "") {
      actualHint = _textAnswerFormat.hint;
      print("Hint: $actualHint");
      if (_textAnswerFormat.hint.contains("\$")) {
        var dynamicKey = _textAnswerFormat.hint.substring(1); // Remove the '$'
        var hintValue = GlobalStateManager().getData(dynamicKey);
        if (hintValue != null) {
          actualHint = hintValue;
        }
        print("Hint after resolving: $actualHint");
      }
    }
  }

  void _initPlaceholder() {
    print("initPlaceholder: ${_textAnswerFormat.placeholder}");
    if (_textAnswerFormat.placeholder != "") {
      if (_textAnswerFormat.placeholder.contains("\$")) {
        var dynamicKey =
            _textAnswerFormat.placeholder.substring(1); // Remove the '$'
        var placeholderValue = GlobalStateManager().getData(dynamicKey);
        if (placeholderValue != null) {
          _controller.text = placeholderValue;
        }
        print("Placeholder after resolving: ${_controller.text}");
      } else {
        _controller.text = _textAnswerFormat.placeholder;
      }
    }
  }

  void _checkValidation(String text) {
    if (widget.questionStep.isOptional) {
      _isValid = true;
      _updateGlobalState(text);
      return;
    }
    setState(() {
      if (_textAnswerFormat.validationRegEx != null) {
        RegExp regExp = RegExp(_textAnswerFormat.validationRegEx!);
        _isValid = regExp.hasMatch(text);
      } else {
        _isValid =
            text.isNotEmpty; // Assume valid if not empty, adjust as needed
      }
    });
    _updateGlobalState(text);
  }

  void _updateGlobalState(String text) {
    // Update the global state with the current text input
    GlobalStateManager()
        .updateData({widget.questionStep.relatedParameter: text});
    print("Updated global state with text: $text");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => TextQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _controller.text,
        result: _controller.text,
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
      isValid: _isValid || widget.questionStep.isOptional,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 32.0, left: 14.0, right: 14.0),
            child: Text(
              widget.questionStep.text,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                fontWeight: Theme.of(context).textTheme.bodyMedium?.fontWeight,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TextField(
            textInputAction: TextInputAction.next,
            minLines: _textAnswerFormat.maxLines ?? 1,
            maxLines: null,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            autofocus: true,
            decoration: textFieldInputDecoration(
              hint: actualHint,
              borderColor: Theme.of(context).colorScheme.outlineVariant,
              hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  fontWeight: Theme.of(context).textTheme.bodyMedium?.fontWeight
              ),
            ),
            controller: _controller,
            textAlign: TextAlign.center,
            onChanged: (String text) {
              _checkValidation(text);
            },
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
              fontWeight: Theme.of(context).textTheme.bodyMedium?.fontWeight,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
