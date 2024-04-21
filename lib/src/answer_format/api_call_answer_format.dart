import 'package:json_annotation/json_annotation.dart';
import 'package:survey_kit/src/answer_format/answer_format.dart';

part 'api_call_answer_format.g.dart';

@JsonSerializable()
class APICallAnswerFormat implements AnswerFormat {
  final String endpointUrl;

  const APICallAnswerFormat({
    this.endpointUrl = '',
  }) : super();

  factory APICallAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$APICallAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$APICallAnswerFormatToJson(this);
}
