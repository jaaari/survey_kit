// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multiple_choice_answer_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultipleChoiceAnswerFormat _$MultipleChoiceAnswerFormatFromJson(
        Map<String, dynamic> json) =>
    MultipleChoiceAnswerFormat(
      textChoices: (json['textChoices'] as List<dynamic>)
          .map((e) => TextChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultSelection: (json['defaultSelection'] as List<dynamic>?)
              ?.map((e) => TextChoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      otherField: json['otherField'] as bool? ?? false,
      maxAnswers: json['maxAnswers'] as int? ?? 100,
      dynamicTextChoices: json['dynamicTextChoices'] as String? ?? '',
      imageChoices: (json['imageChoices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dynamicImageChoices: json['dynamicImageChoices'] as String? ?? '',
      buttonChoices: (json['buttonChoices'] as List<dynamic>)
          .map((e) => TextChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MultipleChoiceAnswerFormatToJson(
        MultipleChoiceAnswerFormat instance) =>
    <String, dynamic>{
      'textChoices': instance.textChoices,
      'defaultSelection': instance.defaultSelection,
      'otherField': instance.otherField,
      'maxAnswers': instance.maxAnswers,
      'dynamicTextChoices': instance.dynamicTextChoices,
      'buttonChoices': instance.buttonChoices,
      'imageChoices': instance.imageChoices,
      'dynamicImageChoices': instance.dynamicImageChoices,
    };
