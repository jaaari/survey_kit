import 'package:survey_kit/src/answer_format/text_choice.dart';
import 'package:survey_kit/src/steps/identifier/identifier.dart';
import 'package:survey_kit/src/result/question_result.dart';

import 'package:json_annotation/json_annotation.dart';

part 'single_choice_audio_question_result.g.dart';

@JsonSerializable(explicitToJson: true)
class SingleChoiceAudioQuestionResult extends QuestionResult<TextChoice?> {
  SingleChoiceAudioQuestionResult({
    required Identifier id,
    required DateTime startDate,
    required DateTime endDate,
    required String valueIdentifier,
    required TextChoice? result,
  }) : super(
          id: id,
          startDate: startDate,
          endDate: endDate,
          valueIdentifier: valueIdentifier,
          result: result,
        );

  factory SingleChoiceAudioQuestionResult.fromJson(Map<String, dynamic> json) => _$SingleChoiceAudioQuestionResultFromJson(json);

  Map<String, dynamic> toJson() => _$SingleChoiceAudioQuestionResultToJson(this);

  @override
  List<Object?> get props => [id, startDate, endDate, valueIdentifier, result];
}
