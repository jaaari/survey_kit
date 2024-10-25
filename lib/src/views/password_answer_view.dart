import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/result/question/password_question_result.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/decoration/input_decoration.dart';

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
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  fontWeight:
                      Theme.of(context).textTheme.titleMedium?.fontWeight,
                  color: Theme.of(context).colorScheme.primary),
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
                borderColor: Theme.of(context).colorScheme.outlineVariant,
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  fontWeight: Theme.of(context).textTheme.bodyMedium?.fontWeight,
                ),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                fontWeight: Theme.of(context).textTheme.bodyMedium?.fontWeight,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
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
                borderColor: Theme.of(context).colorScheme.outlineVariant,
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  fontWeight: Theme.of(context).textTheme.bodyMedium?.fontWeight,
                ),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                fontWeight: Theme.of(context).textTheme.bodyMedium?.fontWeight,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _confirmPasswordController.text.isNotEmpty && !_passwordsMatch,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'Passwords do not match',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
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
