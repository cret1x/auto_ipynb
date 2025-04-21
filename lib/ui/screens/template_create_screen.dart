import 'dart:convert';

import 'package:auto_ipynb/data/model/python_task.dart';
import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/state/templates_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:uuid/uuid.dart';

class TemplateCreateEditScreen extends ConsumerStatefulWidget {
  final Template? template;
  final Template? fileTemplate;

  const TemplateCreateEditScreen({super.key, this.template, this.fileTemplate});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TemplateCreateEditScreen();
}

class _TemplateCreateEditScreen extends ConsumerState<TemplateCreateEditScreen> {
  final _nameEditingController = TextEditingController();
  bool _isEditingName = false;
  final List<PythonTask> tasks = [];
  var _editDesc = <bool>[];

  @override
  void initState() {
    super.initState();
    _nameEditingController.text = 'Новый шаблон';
    if (widget.template != null) {
      _nameEditingController.text = widget.template!.name;
      tasks.addAll(widget.template!.tasks);
      _editDesc = List.filled(tasks.length, false);
    } else if (widget.fileTemplate != null) {
      tasks.addAll(widget.fileTemplate!.tasks);
      _editDesc = List.filled(tasks.length, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: _getDynamicAppBar(),
        body: Column(
          children: [
            _getControlButtons(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => _getTaskCard(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveTemplate() async {
    var uuid = const Uuid();
    final template = Template(
      id: widget.template?.id ?? uuid.v1(),
      name: _nameEditingController.text,
      tasks: tasks,
      maxScore: tasks.map((task) => task.scorePoints).reduce((a, b) => a + b),
    );
    await ref.read(templatesProvider.notifier).save(template);
  }

  void deleteTemplate() async {
    if (widget.template != null) {
      await ref.read(templatesProvider.notifier).delete(widget.template!);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void addAnswer() {
    setState(() {
      tasks.add(PythonTask(isCheckSource: false, isCheckAnswer: false, isCheckPlag: false, scorePoints: 0));
      _editDesc.add(false);
    });
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
                onPressed: () {
                  setState(() {
                    _isEditingName = false;
                  });
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
      ],
    );
  }

  Widget _getControlButtons() {
    return Row(
      children: [
        ElevatedButton(onPressed: saveTemplate, child: const Text("Сохранить")),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton(onPressed: addAnswer, child: const Text("Добавить задание")),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Отмена")),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton(onPressed: widget.template == null ? null : deleteTemplate, child: const Text("Удалить")),
      ],
    );
  }

  Widget _getTaskCard(int taskIndex) {
    final task = tasks[taskIndex];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 10,
                  child: _editDesc[taskIndex] ? TextFormField(
                    initialValue: task.description?.join('') ?? '',
                    maxLines: null,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (description) {
                      setState(() {
                        tasks[taskIndex] = task.copyWith(description: description.split('\n'));
                      });
                    },
                  ) : MarkdownBody(
                    data: task.description?.join('') ?? '',
                    builders: {
                      'latex': LatexElementBuilder(),
                    },
                    selectable: true,
                    extensionSet: md.ExtensionSet(
                      [LatexBlockSyntax()],
                      [LatexInlineSyntax()],
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: IconButton(
                          icon: _editDesc[taskIndex] ? Icon(Icons.done) : Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _editDesc[taskIndex] = !_editDesc[taskIndex];
                            });
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          initialValue: task.scorePoints.toString(),
                          onChanged: (value) {
                            setState(() {
                              tasks[taskIndex] = task.copyWith(scorePoints: double.tryParse(value) ?? 0);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 7,
                    child: TextFormField(
                      initialValue: task.source?.join('') ?? '',
                      maxLines: null,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      style: const TextStyle(color: Colors.black),
                      onChanged: (source) {
                        setState(() {
                          tasks[taskIndex] = task.copyWith(source: source.split('\n'));
                        });
                      },
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: task.isCheckSource,
                              onChanged: (checked) {
                                setState(() {
                                  tasks[taskIndex] = task.copyWith(isCheckSource: checked ?? false, isCheckPlag: (checked ?? false) ? false : null);
                                });
                              },
                            ),
                            Text("Проверять исходный код", style: TextStyle(color: Colors.black),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Checkbox(
                              value: task.isCheckPlag,
                              onChanged: (checked) {
                                setState(() {
                                  tasks[taskIndex] = task.copyWith(isCheckPlag: checked ?? false, isCheckSource: (checked ?? false) ? false : null);
                                });
                              },
                            ),
                            Text("Проверять на плагиат", style: TextStyle(color: Colors.black),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 60, 60, 60),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 7,
                    child: TextFormField(
                      initialValue: task.answer?.join('') ?? '',
                      maxLines: null,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (answer) {
                        setState(() {
                          tasks[taskIndex] = task.copyWith(answer: answer.split('\n'));
                        });
                      },
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Checkbox(
                          value: task.isCheckAnswer,
                          onChanged: (checked) {
                            setState(() {
                              tasks[taskIndex] = task.copyWith(isCheckAnswer: checked ?? false);
                            });
                          },
                        ),
                        Text("Проверять результат выполнения", style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (task.images != null && task.images!.isNotEmpty) Image.memory(base64Decode(task.images!.first))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }
}
