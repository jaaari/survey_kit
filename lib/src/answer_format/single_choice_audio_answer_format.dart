import 'package:json_annotation/json_annotation.dart';
import 'package:survey_kit/src/answer_format/answer_format.dart';
import 'package:survey_kit/src/answer_format/text_choice.dart';

part 'single_choice_audio_answer_format.g.dart';

@JsonSerializable()
class SingleChoiceAudioAnswerFormat implements AnswerFormat {
  final List<TextChoice> textChoices;
  final TextChoice? defaultSelection;
  final String dynamicTextChoices;
  final List<TextChoice> buttonChoices;
  final List<String> imageChoices;
  final String dynamicImageChoices;
  final List<String> audioChoices;

  const SingleChoiceAudioAnswerFormat({
    required this.textChoices,
    this.defaultSelection,
    this.dynamicTextChoices = '',
    required this.buttonChoices,
    this.imageChoices = const [],
    this.dynamicImageChoices = '',
    this.audioChoices = const [],
  }) : super();

  factory SingleChoiceAudioAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$SingleChoiceAudioAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$SingleChoiceAudioAnswerFormatToJson(this);
}
