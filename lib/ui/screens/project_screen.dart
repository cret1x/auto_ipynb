import 'dart:io';

import 'package:auto_ipynb/core/nb_runner.dart';
import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/data/model/student_work.dart';
import 'package:auto_ipynb/state/projects_provider.dart';
import 'package:auto_ipynb/ui/common/action_button.dart';
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
  final libNameController = TextEditingController();
  final _nameEditingController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    runner = NbRunner(
      kernelName: widget.project.id,
      workingDirectory: widget.project.rootPath,
      works: widget.project.studentWorks,
      template: widget.project.template,
    );
    _nameEditingController.text = widget.project.name;
    super.initState();
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    libNameController.dispose();
    super.dispose();
  }

  AppBar _getDynamicAppBar() {
    return AppBar(
      title: _isEditingName
          ? TextFormField(
              controller: _nameEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            )
          : Text(_nameEditingController.text),
      actions: [
        _isEditingName
            ? IconButton(
                onPressed: () async {
                  setState(() {
                    _isEditingName = false;
                  });
                  await ref.read(projectsProvider.notifier).save(Project(
                        id: widget.project.id,
                        name: _nameEditingController.text,
                        rootPath: widget.project.rootPath,
                        studentWorks: widget.project.studentWorks,
                        libraries: widget.project.libraries,
                        template: widget.project.template,
                      ));
                },
                icon: const Icon(Icons.check),
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    _isEditingName = true;
                  });
                },
                icon: const Icon(Icons.edit),
              ),
        DeleteButton(
          onDelete: () async {
            await ref.read(projectsProvider.notifier).delete(widget.project);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: _getDynamicAppBar(),
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
                      'Все работы',
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
                              "Результат: ${studentWork.tasks.map((task) => task.scorePoints).reduce((a, b) => a + b)}/${widget.project.template.maxScore}"),
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
                        'Параметры запуска',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text("Выбранный шаблон проверки:"),
                      const SizedBox(height: 10),
                      Card(
                        surfaceTintColor: Colors.purple,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.project.template.name),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Установленные библиотеки:"),
                      const SizedBox(height: 10),
                      Wrap(
                        runSpacing: 8,
                        spacing: 8,
                        children: widget.project.libraries
                            .map((l) => Chip(
                                  label: Text(l),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: TextFormField(
                          controller: libNameController,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ActionButton(onClick: installLib, child: const Text("Установить библиотеку")),
                      const SizedBox(height: 10),
                      ActionButton(onClick: startRunner, child: const Text("Запустить все")),
                      const SizedBox(height: 10),
                      ActionButton(onClick: checkOutputs, child: const Text("Проверить все")),
                      const SizedBox(height: 10),
                      ActionButton(onClick: checkPlagiarism, child: const Text("Проверить на плагиат")),
                      const SizedBox(height: 10),
                      ActionButton(onClick: createExecutionResult, child: const Text("Создать отчет"))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkPlagiarism() async {
    if (widget.project.libraries.contains('sentence-transformers')) {
      showSimilarityDialog(await runner.checkSimilarity());
    } else {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Установить дополнительную библиотеку sentence-transformers для проверки на плагиат?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Да'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Нет'),
            ),
          ],
        ),
      );
      if (result != null && result) {
        await runner.installLib('sentence-transformers');
        setState(() {
          widget.project.libraries.add('sentence-transformers');
        });

      ref.read(projectsProvider.notifier).save(widget.project);
        showSimilarityDialog(await runner.checkSimilarity());
      }
    }

  }

  void showSimilarityDialog(Map<int, Map<int, List<double?>>> results) {
    showDialog(
      context: context,
      builder: (context) {
        final workIds = results.keys.toList()..sort();
        final taskCount = workIds.isNotEmpty && results[workIds.first]!.isNotEmpty
            ? results[workIds.first]![results[workIds.first]!.keys.first]!.length
            : 0;

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Результат проверки на плагиат',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: workIds.length,
                      itemBuilder: (context, index) {
                        final workId = workIds[index];
                        final comparisons = results[workId]!;
                        final comparedWorkIds = comparisons.keys.toList()..sort();

                        return Card(
                          child: ExpansionTile(
                            title: Text(widget.project.studentWorks[workId].notebookFilename),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: [
                                    const DataColumn(label: Text('Сравнение с')),
                                    ...List.generate(taskCount, (k) => DataColumn(
                                      label: Text('Задание ${k + 1}'),
                                      numeric: true,
                                    )),
                                  ],
                                  rows: comparedWorkIds.map((comparedWorkId) {
                                    final similarities = comparisons[comparedWorkId]!;
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(widget.project.studentWorks[comparedWorkId].notebookFilename)),
                                        ...List.generate(taskCount, (k) {
                                          final value = similarities[k];
                                          return DataCell(
                                            Text(value != null
                                                ? '${(value * 100).toStringAsFixed(1)}%'
                                                : 'N/A'),
                                          );
                                        }),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> checkOutputs() async {
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

  Future<void> startRunner() async {
    for (int i = 0; i < widget.project.studentWorks.length; i++) {
      setState(() {
        widget.project.studentWorks[i] = widget.project.studentWorks[i].changeStatus(RunStatus.running);
      });
      try {
        var err = await runner.run(i);
        setState(() {
          widget.project.studentWorks[i] =
              widget.project.studentWorks[i].copyWith(status: RunStatus.success, errors: err);
        });
      } catch (e) {
        setState(() {
          widget.project.studentWorks[i] =
              widget.project.studentWorks[i].copyWith(status: RunStatus.fail, errors: e.toString());
        });
      }
    }
    ref.read(projectsProvider.notifier).save(widget.project);
  }

  Future<void> installLib() async {
    final lib = libNameController.text;
    libNameController.clear();
    final result = await runner.installLib(lib);
    if (result) {
      setState(() {
        widget.project.libraries.add(lib);
      });
    }
    ref.read(projectsProvider.notifier).save(widget.project);
  }

  Future<void> createExecutionResult() async {
    List<List<dynamic>> csvRows = [];
    List<String> headerRow = [];
    for (int i = 0; i < widget.project.template.tasks.length; i++) {
      headerRow.add("Задание ${i + 1}");
    }
    csvRows.add(["Студент", ...headerRow, "Итог"]);

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
      dialogTitle: 'Выберите место сохранения файла:',
      fileName: 'report.csv',
    );
    if (outputFile != null) {
      File file = File(outputFile);
      await file.writeAsString(csv);
      print("File $outputFile exported successfully!");
    }
  }
}
