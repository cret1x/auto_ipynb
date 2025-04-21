import 'package:auto_ipynb/core/nb_env.dart';
import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/util/directory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

final projectCreationProvider = StreamProviderFamily<String, Project>((ref, project) async* {
  yield "Создание проекта...";
  await Future.delayed(const Duration(seconds: 1));
  yield "Получение Python";
  final python = await getPythonExe();
  await Future.delayed(const Duration(seconds: 1));
  yield "Создание виртуального окружения...";
  await NbEnv.createPythonEnvironment(python, project.rootPath);
  yield "Установка библиотек...";
  await NbEnv.installKernel(project.rootPath, project.id);
  yield "done";
});