// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_call_answer_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

APICallAnswerFormat _$APICallAnswerFormatFromJson(Map<String, dynamic> json) =>
    APICallAnswerFormat(
      endpointUrl: json['endpointUrl'] as String? ?? '',
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
      requestType: json['requestType'] as String? ?? 'POST',
    );

Map<String, dynamic> _$APICallAnswerFormatToJson(
        APICallAnswerFormat instance) =>
    <String, dynamic>{
      'endpointUrl': instance.endpointUrl,
      'parameters': instance.parameters,
      'requestType': instance.requestType,
    };
