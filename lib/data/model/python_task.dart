import 'package:json_annotation/json_annotation.dart';

part 'python_task.g.dart';

@JsonSerializable()
class PythonTask {
  final List<String>? description;
  final List<String>? source;
  final List<String>? answer;
  final bool isCheckSource;
  final bool isCheckAnswer;
  final double scorePoints;

  PythonTask({
    required this.isCheckSource,
    required this.isCheckAnswer,
    required this.scorePoints,
    this.description,
    this.source,
    this.answer,
  });

  factory PythonTask.fromJson(Map<String, dynamic> json) => _$PythonTaskFromJson(json);
  Map<String, dynamic> toJson() => _$PythonTaskToJson(this);


  PythonTask copyWith({
    List<String>? description,
    List<String>? source,
    List<String>? answer,
    bool? isCheckSource,
    bool? isCheckAnswer,
    double? scorePoints,
  }) {
    return PythonTask(
      description: description ?? this.description,
      source: source ?? this.source,
      answer: answer ?? this.answer,
      isCheckSource: isCheckSource ?? this.isCheckSource,
      isCheckAnswer: isCheckAnswer ?? this.isCheckAnswer,
      scorePoints: scorePoints ?? this.scorePoints,
    );
  }
}