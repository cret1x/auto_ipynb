import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/state/project_creation_provider.dart';
import 'package:auto_ipynb/ui/screens/project_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectCreationScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectCreationScreen({super.key, required this.project});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends ConsumerState<ProjectCreationScreen> {
  String text = "";

  @override
  Widget build(BuildContext context) {
    ref.listen(projectCreationProvider(widget.project), (prev, next) {
      if (next.hasValue) {
        print(next);
        if (next.value == 'done') {
          if (mounted) {
            Navigator.pop(context);
          }
        }
        setState(() {
          text = next.value!;
        });
      }
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 10,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
