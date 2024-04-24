import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survey_kit/src/answer_format/text_choice.dart';
import 'package:survey_kit/src/result/question/api_call_result.dart';
import 'package:survey_kit/src/answer_format/api_call_answer_format.dart';
import 'dart:convert';

import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/result/question_result.dart';

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
    _apiCallAnswerFormat = widget.questionStep.answerFormat as APICallAnswerFormat;
    _startDate = DateTime.now();
    _fetchData();
  }

  Future<void> _fetchData() async {
    var headers = {
      'Content-Type': 'application/json'
    };

    try {
      var url = Uri.parse(_apiCallAnswerFormat.endpointUrl);
      var parameters = json.encode(_apiCallAnswerFormat.parameters);
      http.Response response;

      print('API call to ${_apiCallAnswerFormat.endpointUrl} with parameters: $parameters');

      if (_apiCallAnswerFormat.requestType == "POST") {
        response = await http.post(url, headers: headers, body: parameters);
      } else {
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _apiResponse = data.map((item) => TextChoice.fromJson(item as Map<String, dynamic>)).toList();
        });
      } else {
        throw Exception('Failed to load data from API with status code ${response.statusCode}');
      }
    } catch (e) {
      print('API call error: $e');
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
        valueIdentifier: _apiResponse.map((choice) => choice.value).join(','),
        result: _apiResponse,
      ),
      isValid: true,
      title: Text(
        widget.questionStep.title,
        style: Theme.of(context).textTheme.displayMedium,
        textAlign: TextAlign.center,
      ),
      child: _apiResponse.isEmpty
          ? Center(child: Text('Loading...'))
          : Center(child: Text('Received ${_apiResponse.length} items from API'))
    );
  }
}
