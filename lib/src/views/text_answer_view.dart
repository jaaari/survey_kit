import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/src/answer_format/api_call_answer_format.dart';
import 'package:survey_kit/src/answer_format/text_answer_format.dart';
import 'package:survey_kit/src/result/question/text_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/decoration/input_decoration.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/theme_extensions.dart';

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
    final width = MediaQuery.of(context).size.width;

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
              style: context.body,
              textAlign: TextAlign.center)
          : widget.questionStep.content,
      isValid: _isValid || widget.questionStep.isOptional,
      child: Column(
        children: [
          Container(
            width: width * 0.7,
            child: TextField(
              textInputAction: _textAnswerFormat.lines == 1 
                  ? TextInputAction.done 
                  : TextInputAction.newline,
              keyboardType: _textAnswerFormat.lines == 1
                  ? TextInputType.text
                  : TextInputType.multiline,
              maxLines: _textAnswerFormat.lines ?? 8,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.surface,
                hintText: actualHint,
                hintStyle: context.body.copyWith(
                  color: context.textSecondary.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.border),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              controller: _controller,
              onChanged: (String text) {
                _checkValidation(text);
              },
              style: context.body.copyWith(
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}