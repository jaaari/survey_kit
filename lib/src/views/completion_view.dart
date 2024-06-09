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

  void initState() {
    super.initState();
    if (widget.completionStep.text.isNotEmpty && widget.completionStep.text.contains('\$')) {
      text = widget.completionStep.text;
      var dynamicKey = text!.substring(1); // Remove the '$'
      text = GlobalStateManager().getData(dynamicKey) ?? text!;
    }
    else {
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

    http.Response response;
    try {
      print('Making API call to ${widget.completionStep.endpointUrl} with parameters: $parameters');
      if (widget.completionStep.requestType == "POST") {
        print('Making POST request');
        response = await http.post(url, headers: headers, body: parameters);
        print('Response: ${response.body}');
      } else {
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        Provider.of<SurveyController>(context, listen: false).nextStep(context, () => CompletionStepResult(
        widget.completionStep.stepIdentifier,
        _startDate,
        DateTime.now()
      ));
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to make API call: $e';
      });
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
        resolvedParameters[key] = GlobalStateManager().getData(dynamicKey) ?? value;
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
        widget.completionStep.stepIdentifier,
        _startDate,
        DateTime.now()
      ),
      title: Text(
        widget.completionStep.title,
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
          fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
          color: Theme.of(context).colorScheme.primary,
        ),
        textAlign: TextAlign.center,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0),
        child: Column(
          children: [
            Text(
              text!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Theme.of(context).colorScheme.surfaceContainerHigh),
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                    )
                ),
                onPressed: _completeForm,
                child: Text(widget.completionStep.buttonText ?? 'End Survey'),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
