// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_choice_audio_answer_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleChoiceAudioAnswerFormat _$SingleChoiceAudioAnswerFormatFromJson(
        Map<String, dynamic> json) =>
    SingleChoiceAudioAnswerFormat(
      textChoices: (json['textChoices'] as List<dynamic>)
          .map((e) => TextChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultSelection: json['defaultSelection'] == null
          ? null
          : TextChoice.fromJson(
              json['defaultSelection'] as Map<String, dynamic>),
      dynamicTextChoices: json['dynamicTextChoices'] as String? ?? '',
      buttonChoices: (json['buttonChoices'] as List<dynamic>)
          .map((e) => TextChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageChoices: (json['imageChoices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dynamicImageChoices: json['dynamicImageChoices'] as String? ?? '',
      audioChoices: (json['audioChoices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SingleChoiceAudioAnswerFormatToJson(
        SingleChoiceAudioAnswerFormat instance) =>
    <String, dynamic>{
      'textChoices': instance.textChoices,
      'defaultSelection': instance.defaultSelection,
      'dynamicTextChoices': instance.dynamicTextChoices,
      'buttonChoices': instance.buttonChoices,
      'imageChoices': instance.imageChoices,
      'dynamicImageChoices': instance.dynamicImageChoices,
      'audioChoices': instance.audioChoices,
    };
