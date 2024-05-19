// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_call_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

APICallResult _$APICallResultFromJson(Map<String, dynamic> json) =>
    APICallResult(
      id: Identifier.fromJson(json['id'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      valueIdentifier: json['valueIdentifier'] as String,
      result: (json['result'] as List<dynamic>)
          .map((e) => TextChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$APICallResultToJson(APICallResult instance) =>
    <String, dynamic>{
      'id': instance.id?.toJson(),
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'result': instance.result?.map((e) => e.toJson()).toList(),
      'valueIdentifier': instance.valueIdentifier,
    };
