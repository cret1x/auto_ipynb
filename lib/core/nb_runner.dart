import 'dart:convert';
import 'dart:io';

import 'package:auto_ipynb/core/nb_env.dart';
import 'package:auto_ipynb/data/model/student_work.dart';
import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/util/directory.dart';
import 'package:path/path.dart' as path;

class NbRunner {
  final String python;
  final String pip;
  final String kernelName;
  final String workingDirectory;
  final List<StudentWork> works;
  final Template template;

  NbRunner({
    required this.kernelName,
    required this.workingDirectory,
    required this.works,
    required this.template,
  })  : python = path.join(workingDirectory, '.venv', 'scripts', 'python'),
        pip = path.join(workingDirectory, '.venv', 'scripts', 'pip3');

  Future<void> checkOutputs(int workIndex) async {
    final tasks = works[workIndex].tasks;
    if (tasks.length != template.tasks.length) {
      throw Exception("Tasks length mismatch");
    }
    for (int i = 0; i < tasks.length; i++) {
      final teacherTask = template.tasks[i];
      bool flag = true;
      if (teacherTask.isCheckSource) {
        tasks[i] = tasks[i].copyWith(isCheckSource: true);
        flag &= tasks[i].source?.join('') == teacherTask.source?.join('');
      }
      if (teacherTask.isCheckAnswer) {
        tasks[i] = tasks[i].copyWith(isCheckAnswer: true);
        flag &= tasks[i].answer?.join('') == teacherTask.answer?.join('');
      }
      tasks[i] = tasks[i].copyWith(scorePoints: flag ? teacherTask.scorePoints : 0);
    }
  }


  Future<void> checkAndCreateEnv() async {
    final Directory venvDir = Directory(path.join(workingDirectory, '.venv'));
    if (!venvDir.existsSync()) {
      NbEnv.createPythonEnvironment(await getPythonExe(), workingDirectory);
    }
  }

  Future<bool> run(int workIndex) async {
    var result = await Process.run(python, [
      'simple.py',
      path.join(workingDirectory, works[workIndex].notebookFilename),
      kernelName
    ]);
    print(result.stdout);
    print(result.stderr);
    return true;
  }
}
