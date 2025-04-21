// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'python_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PythonTask _$PythonTaskFromJson(Map<String, dynamic> json) => PythonTask(
      isCheckSource: json['isCheckSource'] as bool,
      isCheckAnswer: json['isCheckAnswer'] as bool,
      isCheckPlag: json['isCheckPlag'] as bool,
      scorePoints: (json['scorePoints'] as num).toDouble(),
      description: (json['description'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      source:
          (json['source'] as List<dynamic>?)?.map((e) => e as String).toList(),
      answer:
          (json['answer'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PythonTaskToJson(PythonTask instance) =>
    <String, dynamic>{
      'description': instance.description,
      'source': instance.source,
      'answer': instance.answer,
      'isCheckSource': instance.isCheckSource,
      'isCheckAnswer': instance.isCheckAnswer,
      'isCheckPlag': instance.isCheckPlag,
      'scorePoints': instance.scorePoints,
    };
