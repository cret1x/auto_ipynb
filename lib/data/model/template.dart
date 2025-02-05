import 'dart:convert';
import 'dart:io';

import 'package:auto_ipynb/core/nb_parser.dart';
import 'package:auto_ipynb/data/model/cell.dart';
import 'package:auto_ipynb/data/model/cell_output.dart';
import 'package:auto_ipynb/data/model/cell_output_execute_result.dart';
import 'package:auto_ipynb/data/model/markdown_cell.dart';
import 'package:auto_ipynb/data/model/python_task.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'code_cell.dart';

part 'template.g.dart';

@JsonSerializable()
class Template {
  final String id;
  final String name;
  final List<PythonTask> tasks;
  final double maxScore;

  Template({
    required this.id,
    required this.name,
    required this.tasks,
    required this.maxScore,
  });

  factory Template.fromFile(File file) {
    var uuid = const Uuid();
    var jsonString = file.readAsStringSync();
    Map<String, dynamic> json = jsonDecode(jsonString);
    final nb = NbParser.parseJsonToNotebook("temp", json);
    final tasks = NbParser.getTasksFromNotebook(nb);
    return Template(
      id: uuid.v1(),
      name: path.basename(file.path),
      tasks: tasks,
      maxScore: 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Template) {
      return other.id == id;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}
