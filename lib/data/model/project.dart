import 'package:auto_ipynb/data/model/student_work.dart';
import 'package:auto_ipynb/data/model/template.dart';

class Project {
  final String id;
  final String name;
  final String rootPath;
  final List<StudentWork> studentWorks;
  final List<String> libraries;
  final Template template;
  final DateTime? lastRunTime;

  Project({
    required this.id,
    required this.name,
    required this.rootPath,
    required this.studentWorks,
    required this.libraries,
    required this.template,
    this.lastRunTime,
  });

  @override
  bool operator ==(Object other) {
    if (other is Project) {
      return id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    name: json['name'] as String,
    rootPath: json['rootPath'] as String,
    studentWorks: (json['studentWorks'] as List<dynamic>)
        .map((e) => StudentWork.fromJson(e as Map<String, dynamic>))
        .toList(),
    libraries: (json['libraries'] as List<dynamic>).cast<String>(),
    template: Template.fromJson(json['template'] as Map<String, dynamic>),
    lastRunTime: json['lastRunTime'] == null
        ? null
        : DateTime.parse(json['lastRunTime'] as String),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'rootPath': rootPath,
    'studentWorks': studentWorks,
    'libraries': libraries,
    'template': template,
    'lastRunTime': lastRunTime?.toIso8601String(),
  };
}
