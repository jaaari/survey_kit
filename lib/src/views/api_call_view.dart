import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  Map? _apiResponse;

  @override
  void initState() {
    super.initState();
    _apiCallAnswerFormat =
        widget.questionStep.answerFormat as APICallAnswerFormat;
    _startDate = DateTime.now();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      print('API call to ${_apiCallAnswerFormat.endpointUrl}');
      final response = await http.get(Uri.parse(_apiCallAnswerFormat.endpointUrl));
      if (response.statusCode == 200) {
        setState(() {
          _apiResponse = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load data from API');
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
        valueIdentifier: 'API response',
        result: _apiResponse,
      ),
      isValid: true,
      title: Text(
        widget.questionStep.title,
        style: Theme.of(context).textTheme.displayMedium,
        textAlign: TextAlign.center,
      ),
      child: _apiResponse == null
          ? Center(child: Text('Loading...'))
          : SingleChildScrollView(
              child: Text(_apiResponse.toString()),
            ),
    );
  }
}
