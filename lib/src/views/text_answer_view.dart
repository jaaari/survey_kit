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
  String actualHint = "";

  @override
  void initState() {
    super.initState();
    _textAnswerFormat = widget.questionStep.answerFormat as TextAnswerFormat;
    _controller = TextEditingController();
    _startDate = DateTime.now();
    
    // Set initial text if exists
    final initialText = widget.result?.result ?? _textAnswerFormat.defaultValue ?? '';
    _controller.text = initialText;
    
    // Initialize hint
    if (_textAnswerFormat.hint.isNotEmpty) {
      actualHint = _textAnswerFormat.hint;
      if (actualHint.startsWith('\$')) {
        final dynamicKey = actualHint.substring(1);
        actualHint = GlobalStateManager().getData(dynamicKey) ?? actualHint;
      }
    }

    // Set initial validation state
    _isValid = widget.questionStep.isOptional || _validateText(_controller.text);
  }

  bool _validateText(String text) {
    if (widget.questionStep.isOptional) return true;
    if (_textAnswerFormat.validationRegEx != null) {
      return RegExp(_textAnswerFormat.validationRegEx!).hasMatch(text);
    }
    return text.isNotEmpty;
  }

  void _checkValidation(String text) {
    if (!mounted) return;
    
    final newIsValid = _validateText(text);
    if (_isValid != newIsValid) {
      setState(() {
        _isValid = newIsValid;
      });
    }
    
    if (widget.questionStep.relatedParameter != null) {
      GlobalStateManager().updateData({widget.questionStep.relatedParameter: text});
    }
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
          width: width * 0.7, // Set your desired width here
          height: 100,
          child: 
          TextField(
            textInputAction: TextInputAction.next,
            minLines: _textAnswerFormat.maxLines ?? 1,
            maxLines: null,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            autofocus: true,
            decoration: textFieldInputDecoration(
              hint: actualHint,
              borderColor: context.border,
              hintStyle: context.body.copyWith(color: context.body.color?.withOpacity(0.5)),
            ),
            controller: _controller,
            textAlign: TextAlign.center,
            onChanged: (String text) {
              _checkValidation(text);
            },
            style: context.body,
          ),
          ),
        ],
      ),
    );
  }
}
