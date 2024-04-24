import 'package:json_annotation/json_annotation.dart';
import 'package:survey_kit/src/answer_format/answer_format.dart';

part 'api_call_answer_format.g.dart';

@JsonSerializable()
class APICallAnswerFormat implements AnswerFormat {
  final String endpointUrl;
  final Map parameters;
  final String requestType;

  const APICallAnswerFormat({
    this.endpointUrl = '',
    this.parameters = const {},
    this.requestType = 'POST',
  }) : super();

  factory APICallAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$APICallAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$APICallAnswerFormatToJson(this);
}
