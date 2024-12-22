import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:survey_kit/src/result/question_result.dart';
import 'package:survey_kit/src/result/step/completion_step_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/completion_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'dart:async';
import 'package:survey_kit/src/k_snackbar.dart';
import 'package:survey_kit/src/k_loading_deer.dart';

class CompletionView extends StatefulWidget {
  final CompletionStep completionStep;
  final String assetPath;

  CompletionView({required this.completionStep, this.assetPath = ""});

  @override
  _CompletionViewState createState() => _CompletionViewState();
}

class _CompletionViewState extends State<CompletionView> {
  final DateTime _startDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  String? text;

  @override
  void initState() {
    super.initState();
    if (widget.completionStep.text.isNotEmpty &&
        widget.completionStep.text.contains('\$')) {
      text = widget.completionStep.text;
      var dynamicKey = text!.substring(1);
      text = GlobalStateManager().getData(dynamicKey) ?? text!;
    } else {
      text = widget.completionStep.text;
    }
  }

  Future<void> _completeForm() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  var headers = {'Content-Type': 'application/json'};
  var url = Uri.parse(widget.completionStep.endpointUrl);
  var resolvedParameters = _resolveParameters(widget.completionStep.parameters);
  var parameters = json.encode(resolvedParameters);

  try {
    print('Making API call to ${widget.completionStep.endpointUrl} with parameters: $parameters');
    http.Response response;
    
    if (widget.completionStep.requestType == "POST") {
      print('Making POST request');
      response = await http.post(url, headers: headers, body: parameters);
    } else {
      response = await http.get(url, headers: headers);
    }

    print('Response: ${response.body}');
    if (response.statusCode == 200) {
      Provider.of<SurveyController>(context, listen: false).nextStep(
          context,
          () => CompletionStepResult(widget.completionStep.stepIdentifier,
              _startDate, DateTime.now()));
    } else {
      // Parse the error message from response
      Map<String, dynamic> responseData = json.decode(response.body);
      String errorMessage = responseData['message'] ?? 
          widget.completionStep.errorMessage ?? 
          'Failed to submit survey. Please try again.';
      
      // Close the survey first
      Navigator.of(context).pop();
      // Then show the error snackbar with the parsed message
      KSnackbar.showError(
        context: context,
        message: errorMessage,
      );
    }
  } catch (e) {
    // Close the survey first
    Navigator.of(context).pop();
    // Then show the general error
    KSnackbar.showError(
      context: context,
      message: e.toString(),  // Show the actual error message
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Map<String, dynamic> _resolveParameters(Map<String, dynamic> parameters) {
    var resolvedParameters = Map<String, dynamic>.from(parameters);
    resolvedParameters.forEach((key, value) {
      if (value is String && value.startsWith('\$')) {
        var dynamicKey = value.substring(1); // Remove the '$'
        // fetch the value from the global state manager or leave empty string if not found
        resolvedParameters[key] =
            GlobalStateManager().getData(dynamicKey) ?? "";
      }
    });
    return resolvedParameters;
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.completionStep,
      isValid: false,
      resultFunction: () => CompletionStepResult(
          widget.completionStep.stepIdentifier, _startDate, DateTime.now()),
      title: Text(
        widget.completionStep.title,
        style: context.body.copyWith(color: context.textPrimary),
        textAlign: TextAlign.center,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (text != null && text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Text(
                  text!,
                  style: context.body.copyWith(color: context.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isLoading)
              KLoadingDeer(
                size: context.screenWidth * 0.3,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: context.buttonGradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    ),
                  ),
                  onPressed: _completeForm,
                  child: Text(
                    widget.completionStep.buttonText ?? 'End Survey',
                    style: context.body.copyWith(color: context.textPrimary),
                  ),
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: context.body.copyWith(color: context.accentGreen),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
