import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/state/projects_provider.dart';
import 'package:auto_ipynb/state/python_provider.dart';
import 'package:auto_ipynb/ui/common/exception_widget.dart';
import 'package:auto_ipynb/ui/common/file_load_widget.dart';
import 'package:auto_ipynb/ui/screens/project_screen.dart';
import 'package:auto_ipynb/ui/widgets/create_project_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String? pythonExe = null;

  @override
  Widget build(BuildContext context) {
    final projectsValue = ref.watch(projectsProvider);
    final pythonStatus = ref.watch(pythonProvider);
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("AutoIpynb"),
        ),
        body: pythonStatus.when(
            data: (_) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Все проекты',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: projectsValue.when(
                              data: _getProjectsList,
                              error: (object, trace) => ExceptionWidget(object, trace),
                              loading: () => const CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 600, // Fixed width for the card column
                      child: CreateProjectWidget(),
                    ),
                  ],
                ),
            error: (err, trace) => _noPythonWidget(),
            loading: () => const CircularProgressIndicator()),
      ),
    );
  }

  Widget _noPythonWidget() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Выберите исполняемый файл Python"),
              const SizedBox(
                height: 10,
              ),
              FileLoadWidget(
                extensions: const ['exe'],
                onFileSelected: (file) {
                  setState(() {
                    pythonExe = file.path;
                  });
                },
                onFileCleared: () {
                  setState(() {
                    pythonExe = null;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: pythonExe != null ? () async {
                  if (pythonExe != null) {
                    ref.read(pythonProvider.notifier).setPath(pythonExe!);
                  }
                } : null,
                child: const Text("Сохранить"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getProjectsList(List<Project> projects) {
    return ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ListTile(
            title: Text(project.name),
            subtitle:
                project.lastRunTime != null ? Text("Последнее время проверки: ${project.lastRunTime!.toLocal()}") : null,
            onTap: () => {
              if (mounted)
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectScreen(
                        project: project,
                      ),
                    ),
                  )
                }
            },
          );
        });
  }
}
