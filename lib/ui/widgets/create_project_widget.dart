import 'dart:io';

import 'package:auto_ipynb/core/nb_env.dart';
import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/state/projects_provider.dart';
import 'package:auto_ipynb/ui/common/file_load_widget.dart';
import 'package:auto_ipynb/ui/common/template_select_widget.dart';
import 'package:auto_ipynb/ui/screens/project_creation_screen.dart';
import 'package:auto_ipynb/ui/screens/project_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateProjectWidget extends ConsumerStatefulWidget {
  const CreateProjectWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateProjectWidgetState();
}

class _CreateProjectWidgetState extends ConsumerState<CreateProjectWidget> {
  File? _sourceFile;
  Template? _selectedTemplate;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Создать новый проект',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Text("Выбрать файл"),
          const SizedBox(height: 10,),
          FileLoadWidget(
            extensions: const ['zip', 'ipynb'],
            onFileSelected: onWorkSelected,
            onFileCleared: onWorkCleared,
          ),
          const SizedBox(height: 10,),
          const Text("Выбрать шаблон"),
          TemplateSelectWidget(onTemplateSelected: (template) {
            setState(() {
              _selectedTemplate = template;
            });
          }),
          ElevatedButton(
            onPressed: onCreatePressed,
            child: const Text("Создать"),
          ),
          Visibility(
            visible: error != null,
            child: Text("${error}", style: TextStyle(color: Colors.redAccent),),
          ),
        ],
      ),
    );
  }

  void onWorkSelected(File selectedFile) {
    setState(() {
      _sourceFile = selectedFile;
    });
  }

  void onWorkCleared() {
    setState(() {
      _sourceFile = null;
    });
  }

  void onCreatePressed() async {
    if (_sourceFile != null && _selectedTemplate != null) {
      Project project = await NbEnv.createNewProject(_sourceFile!, _selectedTemplate!);
      await ref.read(projectsProvider.notifier).save(project);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectScreen(
              project: project,
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectCreationScreen(
              project: project,
            ),
          ),
        );
      }
    } else {
      setState(() {
        error = "Выберите файл и шаблон";
      });
    }
  }
}
