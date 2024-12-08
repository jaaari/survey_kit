// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletionStep _$CompletionStepFromJson(Map<String, dynamic> json) =>
    CompletionStep(
      isOptional: json['isOptional'] as bool? ?? false,
      stepIdentifier: StepIdentifier.fromJson(
          json['stepIdentifier'] as Map<String, dynamic>),
      buttonText: json['buttonText'] as String? ?? 'Next',
      showAppBar: json['showAppBar'] as bool? ?? false,
      title: json['title'] as String,
      text: json['text'] as String,
      assetPath: json['assetPath'] as String? ?? "",
      endpointUrl: json['endpointUrl'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
      requestType: json['requestType'] as String? ?? "POST",
      errorMessage: json['errorMessage'] as String? ?? "",
      timeoutMessage: json['timeoutMessage'] as String? ?? "",
    );

Map<String, dynamic> _$CompletionStepToJson(CompletionStep instance) =>
    <String, dynamic>{
      'stepIdentifier': instance.stepIdentifier,
      'isOptional': instance.isOptional,
      'buttonText': instance.buttonText,
      'showAppBar': instance.showAppBar,
      'title': instance.title,
      'text': instance.text,
      'assetPath': instance.assetPath,
      'endpointUrl': instance.endpointUrl,
      'parameters': instance.parameters,
      'requestType': instance.requestType,
      'errorMessage': instance.errorMessage,
      'timeoutMessage': instance.timeoutMessage,
    };
