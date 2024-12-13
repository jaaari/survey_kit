import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/result/question/password_question_result.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/decoration/input_decoration.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/theme_extensions.dart';

class PasswordAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final PasswordQuestionResult? result;

  const PasswordAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _PasswordAnswerViewState createState() => _PasswordAnswerViewState();
}

class _PasswordAnswerViewState extends State<PasswordAnswerView> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _isValid = false;
  bool _passwordsMatch = true;
  bool _passwordTooShort = false;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
    _startDate = DateTime.now();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      // Check if passwords match
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text;

      // Check if the password is at least 6 characters long
      _passwordTooShort = _passwordController.text.length < 6;

      // Validate if all conditions are met
      _isValid = _passwordController.text.isNotEmpty &&
          _passwordsMatch &&
          !_passwordTooShort;
    });
    
    // Update global state if valid
    if (_isValid) {
      _updateGlobalState(_passwordController.text);
    }
  }

  void _updateGlobalState(String password) {
    // Store the password in the global state with a key
    GlobalStateManager()
        .updateData({widget.questionStep.relatedParameter: password});
    print("Updated global state with password: $password");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return StepView(
      step: widget.questionStep,
      resultFunction: () => PasswordQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _passwordController.text,
        result: _passwordController.text,
      ),
      title: widget.questionStep.title.isNotEmpty
          ? Text(widget.questionStep.title,
              style: context.body,
              textAlign: TextAlign.center)
          : widget.questionStep.content,
      isValid: _isValid || widget.questionStep.isOptional,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width * 0.7,
            height: 80,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              decoration: textFieldInputDecoration(
                hint: 'Enter Password',
                borderColor: context.border,
                hintStyle: context.body.copyWith(color: context.textSecondary.withOpacity(0.5))
              ),
              textAlign: TextAlign.center,
              style: context.body,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: width * 0.7,
            height: 80,
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              autofocus: true,
              decoration: textFieldInputDecoration(
                hint: 'Confirm Password',
                borderColor: context.border,
                hintStyle: context.body.copyWith(color: context.textSecondary.withOpacity(0.5))
              ),
              textAlign: TextAlign.center,
              style: context.body,
            ),
          ),
          SizedBox(
            height: height * 0.06,
            child: Column(
              children: [
                Visibility(
                  visible: _passwordController.text.isNotEmpty && _passwordTooShort,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'Password must be at least 6 characters',
                      style: context.caption.copyWith(color: context.primaryPurple),
                    ),
                  ),
                ),
                Visibility(
                  visible: _confirmPasswordController.text.isNotEmpty && !_passwordsMatch,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'Passwords do not match',
                      style: context.caption.copyWith(color: context.primaryPurple),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
