import 'package:json_annotation/json_annotation.dart';
import 'package:survey_kit/src/answer_format/answer_format.dart';

part 'password_answer_format.g.dart';

@JsonSerializable()
class PasswordAnswerFormat implements AnswerFormat {
  final int? minLength;
  final int? maxLength;
  @JsonKey(defaultValue: '')
  final String hint;
  final String placeholder;

  /// Regular expression to validate password strength
  /// For example, to require at least one uppercase, one lowercase, one number, and a special character
  @JsonKey(defaultValue: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$')
  final String? validationRegEx;

  const PasswordAnswerFormat({
    this.minLength,
    this.maxLength,
    this.hint = '',
    this.placeholder = '',
    this.validationRegEx = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$', // Example strong password regex
  }) : super();

  factory PasswordAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$PasswordAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordAnswerFormatToJson(this);
}
