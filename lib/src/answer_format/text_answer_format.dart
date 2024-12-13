import 'package:json_annotation/json_annotation.dart';
import 'package:survey_kit/src/answer_format/answer_format.dart';

part 'text_answer_format.g.dart';

@JsonSerializable()
class TextAnswerFormat implements AnswerFormat {
  final String? validationRegEx;
  final String hint;
  final String placeholder;
  final String? defaultValue;
  final int? lines;

  const TextAnswerFormat({
    this.validationRegEx,
    this.hint = '',
    this.placeholder = '',
    this.defaultValue,
    this.lines,
  }) : super();

  factory TextAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$TextAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$TextAnswerFormatToJson(this);
}
