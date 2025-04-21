import 'dart:async';

import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/data/repository/project_repository.dart';
import 'package:auto_ipynb/util/directory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectsNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    return ProjectRepository.loadProjectsFromFile();
  }

  Future<void> save(Project project) async {
    if (state.hasValue) {
      var projects = state.value!;
      if (projects.contains(project)) {
        final modifiedProjects = [
          for (final p in projects)
            if (p.id == project.id) project else p
        ];
        await ProjectRepository.saveProjects(modifiedProjects.map((p) => p.id).toList(), project);
        state = AsyncValue.data(modifiedProjects);
      } else {
        final modifiedProjects = [...projects, project];
        await ProjectRepository.saveProjects(modifiedProjects.map((p) => p.id).toList(), project);
        state = AsyncValue.data(modifiedProjects);
      }
    }
  }

  Future<void> delete(Project project) async {
    if (state.hasValue) {
      final projects = state.value!.where((p) => p.id != project.id).toList();
      await ProjectRepository.saveProjects(projects.map((p) => p.id).toList(), project, isDelete: true);
      await deleteProjectDirectory(project.id);
      state = AsyncValue.data(projects);
    }
  }
}

final projectsProvider = AsyncNotifierProvider<ProjectsNotifier, List<Project>>(ProjectsNotifier.new);
