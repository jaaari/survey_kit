import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survey_kit/src/answer_format/text_choice.dart';
import 'package:survey_kit/src/result/question/api_call_result.dart';
import 'package:survey_kit/src/answer_format/api_call_answer_format.dart';
import 'dart:convert';

import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/result/question_result.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:provider/provider.dart';
import 'global_state_manager.dart';

class APICallView extends StatefulWidget {
  final QuestionStep questionStep;
  final QuestionResult? result;

  const APICallView({
    Key? key,
    required this.questionStep,
    this.result,
  }) : super(key: key);

  @override
  _APICallViewState createState() => _APICallViewState();
}

class _APICallViewState extends State<APICallView> {
  late final DateTime _startDate;
  late final APICallAnswerFormat _apiCallAnswerFormat;
  List<TextChoice> _apiResponse = [];

  @override
  void initState() {
    super.initState();
    _apiCallAnswerFormat =
        widget.questionStep.answerFormat as APICallAnswerFormat;
    _startDate = DateTime.now();
    _fetchData();
  }

  // Utility function to resolve dynamic parameters
  Map<String, dynamic> _resolveParameters(Map<String, dynamic> parameters) {
    var resolvedParameters = Map<String, dynamic>.from(parameters);
    resolvedParameters.forEach((key, value) {
      print("Resolving parameter: $key with value: $value");
      if (value is String && value.startsWith('\$')) {
        var dynamicKey = value.substring(1); // Remove the '$'
        resolvedParameters[key] =
            GlobalStateManager().getData(dynamicKey) ?? value;
      }
    });
    return resolvedParameters;
  }

  Future<void> _fetchData() async {
    var headers = {'Content-Type': 'application/json'};

    try {
      var url = Uri.parse(_apiCallAnswerFormat.endpointUrl);
      var resolvedParameters =
          _resolveParameters(_apiCallAnswerFormat.parameters);
      var parameters = json.encode(resolvedParameters);
      http.Response response;

      print(
          'API call to ${_apiCallAnswerFormat.endpointUrl} with resolved parameters: $parameters');

      if (_apiCallAnswerFormat.requestType == "POST") {
        response = await http.post(url, headers: headers, body: parameters);
      } else {
        response = await http.get(url, headers: headers);
      }
      print("API call status: ${response.statusCode}");
      print("API call response: ${response.body}");

      if (response.statusCode == 200) {
        print("API call status 200 with response: ${response.body}");

        // Decode the JSON response once and reuse the decoded map
        Map<String, dynamic> responseData = json.decode(response.body);

        // Update global state
        GlobalStateManager().updateData(responseData);

        // Handle response data and update local state
        List<dynamic> data = [];
        for (var key in responseData.keys) {
          if (responseData[key] is List) {
            var firstItem = responseData[key].first;
            if (firstItem is Map<String, dynamic> &&
                firstItem.containsKey('text') &&
                firstItem.containsKey('value')) {
              data = responseData[key];
              break;
            }
          }
        }

        if (data.isNotEmpty) {
          print("Updating local state with data: $data");
          setState(() {
            _apiResponse = [
              TextChoice.fromJson(data.first as Map<String, dynamic>)
            ];
          });
          print("API call response: $_apiResponse");
        } else {
          print(
              "No suitable list found in the API response to update _apiResponse.");
        }

        // navigate to next step
        final resultFunction = () => APICallResult(
              id: widget.questionStep.stepIdentifier,
              startDate: _startDate,
              endDate: DateTime.now(),
              valueIdentifier:
                  _apiResponse.map((choice) => choice.value).join(','),
              result: _apiResponse,
            );
        Provider.of<SurveyController>(context, listen: false)
            .nextStep(context, resultFunction);

        print("Global state: ${GlobalStateManager().getAllData()}");
      } else {
        print(
            'Failed to load data from API with status code: ${response.statusCode} and body: ${response.body}');
        throw Exception(
            'Failed to load data from API with status code: ${response.statusCode}' +
                ' and body: ${response.body}');
      }
    } catch (e) {
      print('API call error: $e');
      // display error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('API Call Error'),
            content: Text('Failed to load data from API: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
        step: widget.questionStep,
        resultFunction: () => APICallResult(
              id: widget.questionStep.stepIdentifier,
              startDate: _startDate,
              endDate: DateTime.now(),
              valueIdentifier:
                  _apiResponse.map((choice) => choice.value).join(','),
              result: _apiResponse,
            ),
        isValid: false,
        title: Text(
          widget.questionStep.title,
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        child: _apiResponse.isEmpty
            ? Center(child: Text('Loading...'))
            : Center(
                child: Text('Received ${_apiResponse.length} items from API')));
  }
}
