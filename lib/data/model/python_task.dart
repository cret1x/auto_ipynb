import 'package:json_annotation/json_annotation.dart';

part 'python_task.g.dart';

@JsonSerializable()
class PythonTask {
  final List<String>? description;
  final List<String>? source;
  final List<String>? answer;
  final List<String>? images;
  final bool isCheckSource;
  final bool isCheckAnswer;
  final bool isCheckPlag;
  final double scorePoints;

  PythonTask({
    required this.isCheckSource,
    required this.isCheckAnswer,
    required this.isCheckPlag,
    required this.scorePoints,
    this.description,
    this.source,
    this.answer,
    this.images,
  });

  factory PythonTask.fromJson(Map<String, dynamic> json) => _$PythonTaskFromJson(json);
  Map<String, dynamic> toJson() => _$PythonTaskToJson(this);


  PythonTask copyWith({
    List<String>? description,
    List<String>? source,
    List<String>? answer,
    List<String>? images,
    bool? isCheckSource,
    bool? isCheckAnswer,
    bool? isCheckPlag,
    double? scorePoints,
  }) {
    return PythonTask(
      description: description ?? this.description,
      source: source ?? this.source,
      answer: answer ?? this.answer,
      images: images ?? this.images,
      isCheckSource: isCheckSource ?? this.isCheckSource,
      isCheckAnswer: isCheckAnswer ?? this.isCheckAnswer,
      isCheckPlag: isCheckPlag ?? this.isCheckPlag,
      scorePoints: scorePoints ?? this.scorePoints,
    );
  }
}