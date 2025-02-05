import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/state/projects_provider.dart';
import 'package:auto_ipynb/ui/common/exception_widget.dart';
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
  @override
  Widget build(BuildContext context) {
    final projectsValue = ref.watch(projectsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoIpynb"),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'All projects',
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
    );
  }

  Widget _getProjectsList(List<Project> projects) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ListTile(
          title: Text(project.name),
          trailing: project.lastRunTime != null ? Text("Last run: ${project.lastRunTime}") : null,
          onTap: () =>
          {
            if (mounted)
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProjectScreen(
                          project: project,
                        ),
                  ),
                )
              }
          },
        );
      }
    );
  }
}
