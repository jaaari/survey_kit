import 'package:survey_kit/src/steps/identifier/identifier.dart';
import 'package:survey_kit/src/result/question_result.dart';

import 'package:json_annotation/json_annotation.dart';

part 'password_question_result.g.dart';

@JsonSerializable(explicitToJson: true)
class PasswordQuestionResult extends QuestionResult<String?> {
  PasswordQuestionResult({
    required Identifier id,
    required DateTime startDate,
    required DateTime endDate,
    required String valueIdentifier,
    required String? result,
  }) : super(
          id: id,
          startDate: startDate,
          endDate: endDate,
          valueIdentifier: valueIdentifier,
          result: result,
        );

  factory PasswordQuestionResult.fromJson(Map<String, dynamic> json) => _$PasswordQuestionResultFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordQuestionResultToJson(this);

  @override
  List<Object?> get props => [id, startDate, endDate, valueIdentifier, result];
}
