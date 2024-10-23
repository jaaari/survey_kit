// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_answer_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordAnswerFormat _$PasswordAnswerFormatFromJson(
        Map<String, dynamic> json) =>
    PasswordAnswerFormat(
      minLength: (json['minLength'] as num?)?.toInt(),
      maxLength: (json['maxLength'] as num?)?.toInt(),
      hint: json['hint'] as String? ?? '',
      placeholder: json['placeholder'] as String? ?? '',
      validationRegEx: json['validationRegEx'] as String? ??
          '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[\\W_]).{8,}\$',
    );

Map<String, dynamic> _$PasswordAnswerFormatToJson(
        PasswordAnswerFormat instance) =>
    <String, dynamic>{
      'minLength': instance.minLength,
      'maxLength': instance.maxLength,
      'hint': instance.hint,
      'placeholder': instance.placeholder,
      'validationRegEx': instance.validationRegEx,
    };
