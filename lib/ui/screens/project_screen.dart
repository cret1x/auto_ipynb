import 'dart:io';

import 'package:auto_ipynb/core/nb_runner.dart';
import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/data/model/student_work.dart';
import 'package:auto_ipynb/state/projects_provider.dart';
import 'package:auto_ipynb/ui/common/delete_button.dart';
import 'package:auto_ipynb/ui/screens/student_work_screen.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectScreen({super.key, required this.project});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  late NbRunner runner;

  @override
  void initState() {
    runner = NbRunner(
      kernelName: widget.project.id,
      workingDirectory: widget.project.rootPath,
      works: widget.project.studentWorks,
      template: widget.project.template,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          DeleteButton(
            onDelete: () async {
              await ref.read(projectsProvider.notifier).delete(widget.project);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'All files',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.project.studentWorks.length,
                    itemBuilder: (context, index) {
                      var studentWork = widget.project.studentWorks[index];
                      return ListTile(
                        title: Text(studentWork.notebookFilename),
                        trailing: switch (studentWork.status) {
                          RunStatus.pending => const Icon(
                              Icons.timer,
                              color: Colors.grey,
                            ),
                          RunStatus.running => const CircularProgressIndicator(
                              color: Colors.yellow,
                            ),
                          RunStatus.success => const Icon(
                              Icons.check,
                              color: Colors.lightGreen,
                            ),
                          RunStatus.checked => const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                          RunStatus.fail => const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                        },
                        subtitle: Text(
                            "Score: ${studentWork.tasks.map((task) => task.scorePoints).reduce((a, b) => a + b)}/${widget.project.template.maxScore}"),
                        onTap: () {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentWorkScreen(
                                  studentWork: studentWork,
                                  template: widget.project.template,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 300,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Run settings',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Selected template:"),
                    const SizedBox(height: 10),
                    Card(
                      surfaceTintColor: Colors.purple,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.project.template.name),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Selected environment:"),
                    const SizedBox(height: 10),
                    const Card(
                      surfaceTintColor: Colors.purple,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Python 3"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: startRunner, child: const Text("Run all")),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: checkOutputs, child: const Text("Check all")),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: createExecutionResult, child: const Text("Create execution result"))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkOutputs() async {
    for (int i = 0; i < widget.project.studentWorks.length; i++) {
      setState(() {
        widget.project.studentWorks[i] = widget.project.studentWorks[i].changeStatus(RunStatus.running);
      });
      try {
        await runner.checkOutputs(i);
        setState(() {
          widget.project.studentWorks[i] = widget.project.studentWorks[i].changeStatus(RunStatus.checked);
        });
      } catch (e) {
        setState(() {
          widget.project.studentWorks[i] = widget.project.studentWorks[i].changeStatus(RunStatus.fail);
        });
      }
    }
    ref.read(projectsProvider.notifier).save(widget.project);
  }

  void startRunner() async {
    for (int i = 0; i < widget.project.studentWorks.length; i++) {
      setState(() {
        widget.project.studentWorks[i] = widget.project.studentWorks[i].changeStatus(RunStatus.running);
      });
      try {
        await runner.run(i);
        setState(() {
          widget.project.studentWorks[i] = widget.project.studentWorks[i].changeStatus(RunStatus.success);
        });
      } catch (e) {
        setState(() {
          widget.project.studentWorks[i] = widget.project.studentWorks[i].changeStatus(RunStatus.fail);
        });
      }
    }
    ref.read(projectsProvider.notifier).save(widget.project);
  }

  void createExecutionResult() async {
    List<List<dynamic>> csvRows = [];
    List<String> headerRow = [];
    for (int i = 0; i < widget.project.template.tasks.length; i++) {
      headerRow.add("Task ${i + 1}");
    }
    csvRows.add(["Student", ...headerRow, "Total"]);

    for (int rowIdx = 0; rowIdx < widget.project.studentWorks.length; rowIdx++) {
      final work = widget.project.studentWorks[rowIdx];
      List<dynamic> row = [work.notebookFilename];
      double total = 0;
      for (int i = 0; i < work.tasks.length; i++) {
        row.add(work.tasks[i].scorePoints);
        total += work.tasks[i].scorePoints;
      }
      row.add(total);
      csvRows.add(row);
    }

    String csv = const ListToCsvConverter().convert(csvRows, fieldDelimiter: ';');
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'report.csv',
    );
    if (outputFile != null) {
      File file = File(outputFile);
      await file.writeAsString(csv);
      print("File $outputFile exported successfully!");
    }
  }
}
