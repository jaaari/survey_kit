// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionStep _$QuestionStepFromJson(Map<String, dynamic> json) => QuestionStep(
      isOptional: json['isOptional'] as bool? ?? false,
      buttonText: json['buttonText'] as String? ?? 'Next',
      stepIdentifier: json['stepIdentifier'] == null
          ? null
          : StepIdentifier.fromJson(
              json['stepIdentifier'] as Map<String, dynamic>),
      showAppBar: json['showAppBar'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      relatedParameter: json['relatedParameter'] as String? ?? '',
      relatedTextChoiceParameter:
          json['relatedTextChoiceParameter'] as String? ?? '',
      infoText: json['infoText'] as String? ?? '',
      answerFormat:
          AnswerFormat.fromJson(json['answerFormat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuestionStepToJson(QuestionStep instance) =>
    <String, dynamic>{
      'stepIdentifier': instance.stepIdentifier,
      'isOptional': instance.isOptional,
      'buttonText': instance.buttonText,
      'showAppBar': instance.showAppBar,
      'title': instance.title,
      'text': instance.text,
      'relatedParameter': instance.relatedParameter,
      'relatedTextChoiceParameter': instance.relatedTextChoiceParameter,
      'answerFormat': instance.answerFormat,
      'infoText': instance.infoText,
    };
