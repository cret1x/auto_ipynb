import 'dart:convert';
import 'dart:io';

import 'package:auto_ipynb/core/nb_env.dart';
import 'package:auto_ipynb/core/nb_parser.dart';
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

  Future<bool> installLib(String lib) async {
    try {
      await NbEnv.installLibs(pip, workingDirectory, [lib]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> checkAndCreateEnv() async {
    final Directory venvDir = Directory(path.join(workingDirectory, '.venv'));
    if (!venvDir.existsSync()) {
      NbEnv.createPythonEnvironment(await getPythonExe(), workingDirectory);
    }
  }

  Future<Map<int, Map<int, List<double?>>>> checkSimilarity() async {
    final score = <int, Map<int, List<double?>>>{};

    for (int i = 0; i < works.length; i++) {
      score[i] = <int, List<double?>>{};
    }

    for (int i = 0; i < works.length; i++) {
      final tasksA = works[i].tasks;

      for (int j = 0; j < works.length; j++) {
        if (i == j) continue;

        final tasksB = works[j].tasks;
        print("Comparing work $i with work $j");

        score[i]![j] = List.filled(tasksA.length, null);

        for (int k = 0; k < tasksA.length; k++) {
          if (template.tasks[k].isCheckPlag && k < tasksB.length) {
            try {
              var result = await Process.run(python, [
                'plagiarism.py',
                tasksA[k].source?.join('') ?? 'A',
                tasksB[k].source?.join('') ?? 'B',
              ]);
              score[i]![j]![k] = double.tryParse(result.stdout);
            } catch (e) {
              print('Error comparing task $k between works $i and $j: $e');
              score[i]![j]![k] = null;
            }
          } else {
            score[i]![j]![k] = null;
          }
        }
      }
    }

    print(score);
    return score;
  }

  Future<String?> run(int workIndex) async {
    var result = await Process.run(
        python, ['executor.py', path.join(workingDirectory, works[workIndex].notebookFilename), kernelName]);
    print(result.stdout);
    print(result.stderr);
    if (result.stderr.toString().isNotEmpty) {
      if (result.stderr.toString().contains("ModuleNotFoundError")) {
        throw Exception(result.stderr);
      }
      return result.stderr;
    }
    return null;
  }
}
