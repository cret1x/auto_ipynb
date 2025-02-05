import 'dart:convert';
import 'dart:io';

import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/util/directory.dart';

class ProjectRepository {
  static Future<void> saveProjects(List<String> projectsIds, Project project, {bool isDelete = false}) async {
    final directory = await getAppDirectory();
    final projectDirectory = await getProjectsDirectory();
    final projectsListFile = File('${directory.path}/projects.json');
    final projectFile = File('${projectDirectory.path}/${project.id}.json');

    // Convert project list
    final projectsListJson = jsonEncode(projectsIds);
    await projectsListFile.writeAsString(projectsListJson);
    print('Projects list saved to: ${projectsListFile.path}');

    // Save or update project
    if (isDelete) {
      await projectFile.delete();
      print('Project deleted');
      return;
    }
    final projectJson = jsonEncode(project.toJson());
    await projectFile.writeAsString(projectJson);
    print('Project saved to: ${projectFile.path}');
  }

  static Future<List<Project>> loadProjectsFromFile() async {
    // Get the documents directory
    final directory = await getAppDirectory();
    final projectDirectory = await getProjectsDirectory();
    final projectsListFile = File('${directory.path}/projects.json');

    // Check if the file exists
    if (await projectsListFile.exists()) {
      // Read the file
      final jsonString = await projectsListFile.readAsString();
      // Convert JSON back to templates
      final List<dynamic> projectsIds = jsonDecode(jsonString);
      final List<dynamic> projects = [];
      for (var pid in projectsIds) {
        final projectFile = File('${projectDirectory.path}/$pid.json');
        if (projectFile.existsSync()) {
          final projectJsonString = await projectFile.readAsString();
          projects.add(jsonDecode(projectJsonString));
        }
      }
      return projects.map((json) => Project.fromJson(json)).toList();
    } else {
      print('No projects file found.');
      return [];
    }
  }
}
