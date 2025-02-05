import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:auto_ipynb/core/nb_parser.dart';
import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/data/model/student_work.dart';
import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/util/directory.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class NbEnv {
  static Future<Project> createNewProject(File sourceFile, Template template) async {
    const uuid = Uuid();
    final projectId = uuid.v1();
    final appDir = await getAppDirectory();
    final Directory projectDir = Directory(path.join(appDir.path, projectId));
    if (!projectDir.existsSync()) {
      await projectDir.create();
    }
    final filename = path.basename(sourceFile.path);
    final ext = path.extension(sourceFile.path);
    late List<String> filesList;
    if (ext == '.ipynb') {
      print('Direct import');
      filesList = [filename];
      await sourceFile.copy(path.join(projectDir.path, filename));
    } else if (ext == '.zip') {
      print('Archive');
      final inputStream = InputFileStream(sourceFile.path);
      final archive = ZipDecoder().decodeStream(inputStream);
      filesList = archive.files.where((e) => e.isFile).map((e) => e.name).toList();
      await extractArchiveToDisk(archive, projectDir.path);
    } else {
      throw Exception("Incorrect file format!");
    }
    return Project(
      id: projectId,
      name: 'Unnamed',
      rootPath: projectDir.path,
      studentWorks: List.of(filesList.map((f) => fromFile(projectDir.path, f))),
      template: template,
    );
  }

  static StudentWork fromFile(String rootPath, String filename) {
    var file = File(path.join(rootPath, filename));
    var jsonString = file.readAsStringSync();
    Map<String, dynamic> json = jsonDecode(jsonString);
    final notebook = NbParser.parseJsonToNotebook(filename, json);
    final tasks = NbParser.getTasksFromNotebook(notebook);
    return StudentWork(notebookFilename: filename, tasks: tasks, status: RunStatus.pending);
  }

  static Future<void> createPythonEnvironment(String pythonExe, String workingDirectory) async {
    final Directory venvDir = Directory(path.join(workingDirectory, '.venv'));
    if (!venvDir.existsSync()) {
      print('Creating pyhton environment');
      await Process.run(pythonExe, ["-m", "venv", ".venv"], workingDirectory: workingDirectory);
    }
  }

  static Future<void> installKernel(String workingDirectory, String kernelName) async {
    print('Installing kernel');
    final python = path.join(workingDirectory, '.venv', 'scripts', 'python');
    final pip = path.join(workingDirectory, '.venv', 'scripts', 'pip3');
    await installLibs(pip, workingDirectory, ['ipykernel', 'nbformat', 'nbclient']);
    print('Setting up Jupyter kernel...');
    await Process.run(python, [
      '-m',
      'ipykernel',
      'install',
      '--user',
      '--name=$kernelName',
      '--display-name',
      'Python ($kernelName)'
    ]);
  }

  static Future<void> installLibs(String pipExe, String workingDirectory, List<String> libs) async {
    print('Installing libraries: $libs');
    await Process.run(pipExe, ['install', ...libs], workingDirectory: workingDirectory);
  }

// static Future<List<String>> getInstalledLibs() async {
//   await checkAndCreateEnv();
//   print('Listing libraries...');
//   final result = await Process.run(pip, ['list', 'installed']);
//   return (result.stdout as String).split('\n').toList();
// }
}
