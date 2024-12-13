// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_answer_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextAnswerFormat _$TextAnswerFormatFromJson(Map<String, dynamic> json) =>
    TextAnswerFormat(
      validationRegEx: json['validationRegEx'] as String?,
      hint: json['hint'] as String? ?? '',
      placeholder: json['placeholder'] as String? ?? '',
      defaultValue: json['defaultValue'] as String?,
      lines: (json['lines'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TextAnswerFormatToJson(TextAnswerFormat instance) =>
    <String, dynamic>{
      'validationRegEx': instance.validationRegEx,
      'hint': instance.hint,
      'placeholder': instance.placeholder,
      'defaultValue': instance.defaultValue,
      'lines': instance.lines,
    };
