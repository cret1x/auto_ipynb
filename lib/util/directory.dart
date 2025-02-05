import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<Directory> getAppDirectory() async {
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  String appDirPath = path.join(documentsDir.path, 'auto_ipynb');
  final Directory appDir = Directory(appDirPath);
  if (!appDir.existsSync()) {
    await appDir.create();
  }
  return appDir;
}

Future<Directory> getTemplatesDirectory() async {
  final Directory appDir = await getAppDirectory();
  String templatesPath = path.join(appDir.path, 'templates');
  final Directory templatesDir = Directory(templatesPath);
  if (!templatesDir.existsSync()) {
    await templatesDir.create();
  }
  return templatesDir;
}

Future<Directory> getProjectsDirectory() async {
  final Directory appDir = await getAppDirectory();
  String projectsPath = path.join(appDir.path, 'projects');
  final Directory projectsDir = Directory(projectsPath);
  if (!projectsDir.existsSync()) {
    await projectsDir.create();
  }
  return projectsDir;
}

Future<void> deleteProjectDirectory(String id) async {
  final projectsDir = await getAppDirectory();
  String projectPath = path.join(projectsDir.path, id);
  final Directory projectDir = Directory(projectPath);
  await projectDir.delete(recursive: true);
}

Future<String> getPythonExe() async {
  return "py";
}
