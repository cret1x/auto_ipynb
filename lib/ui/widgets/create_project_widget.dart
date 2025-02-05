import 'dart:io';

import 'package:auto_ipynb/core/nb_env.dart';
import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/state/projects_provider.dart';
import 'package:auto_ipynb/state/templates_provider.dart';
import 'package:auto_ipynb/ui/common/exception_widget.dart';
import 'package:auto_ipynb/ui/common/file_load_widget.dart';
import 'package:auto_ipynb/ui/common/template_select_widget.dart';
import 'package:auto_ipynb/ui/screens/project_creation_screen.dart';
import 'package:auto_ipynb/ui/screens/project_screen.dart';
import 'package:auto_ipynb/ui/screens/template_create_screen.dart';
import 'package:file_picker/file_picker.dart';
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
              'Create new project',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Text("Select file"),
          FileLoadWidget(
            extensions: const ['zip', 'ipynb'],
            onFileSelected: onWorkSelected,
            onFileCleared: onWorkCleared,
          ),
          const Text("Select template"),
          TemplateSelectWidget(onTemplateSelected: (template) {
            setState(() {
              _selectedTemplate = template;
            });
          }),
          ElevatedButton(
            onPressed: onCreatePressed,
            child: const Text("Create"),
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
      ref.read(projectsProvider.notifier).save(project);
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
    }
  }
}
