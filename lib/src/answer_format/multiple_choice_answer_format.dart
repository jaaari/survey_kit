import 'package:json_annotation/json_annotation.dart';
import 'package:survey_kit/src/answer_format/answer_format.dart';
import 'package:survey_kit/src/answer_format/text_choice.dart';

part 'multiple_choice_answer_format.g.dart';

@JsonSerializable()
class MultipleChoiceAnswerFormat implements AnswerFormat {
  final List<TextChoice> textChoices;
  @JsonKey(defaultValue: const [])
  final List<TextChoice> defaultSelection;
  @JsonKey(defaultValue: false)
  final bool otherField;
  @JsonKey(defaultValue: 100)
  final int maxAnswers;
  @JsonKey(defaultValue: '')
  final String dynamicTextChoices;
  final List<TextChoice> buttonChoices;
  final List<String> imageChoices;
  final String dynamicImageChoices;

  const MultipleChoiceAnswerFormat({
    required this.textChoices,
    this.defaultSelection = const [],
    this.otherField = false,
    this.maxAnswers = 100,
    this.dynamicTextChoices = '',
    this.imageChoices = const [],
    this.dynamicImageChoices = '',
    required this.buttonChoices,
  }) : super();

  factory MultipleChoiceAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$MultipleChoiceAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$MultipleChoiceAnswerFormatToJson(this);
}
