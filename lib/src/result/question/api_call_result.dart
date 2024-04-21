import 'package:survey_kit/src/result/question_result.dart';
import 'package:survey_kit/src/steps/identifier/identifier.dart';

import 'package:json_annotation/json_annotation.dart';

part 'api_call_result.g.dart';

@JsonSerializable(explicitToJson: true)
class APICallResult extends QuestionResult<Map?> {
  APICallResult({
    required Identifier id,
    required DateTime startDate,
    required DateTime endDate,
    required String valueIdentifier,
    required Map? result,
  }) : super(
          id: id,
          startDate: startDate,
          endDate: endDate,
          valueIdentifier: valueIdentifier,
          result: result,
        );

  factory APICallResult.fromJson(Map<String, dynamic> json) => _$APICallResultFromJson(json);

  Map<String, dynamic> toJson() => _$APICallResultToJson(this);

  @override
  List<Object?> get props => [id, startDate, endDate, valueIdentifier, result];
}
