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

  @override
  void initState() {
    super.initState();
    _nameEditingController.text = 'New template';
    if (widget.template != null) {
      _nameEditingController.text = widget.template!.name;
      tasks.addAll(widget.template!.tasks);
    } else if (widget.fileTemplate != null) {
      tasks.addAll(widget.fileTemplate!.tasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getDynamicAppBar(),
      body: Column(
        children: [
          _getControlButtons(),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => _getTaskCard(index),
            ),
          ),
        ],
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
      tasks.add(PythonTask(isCheckSource: false, isCheckAnswer: false, scorePoints: 0));
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
        ElevatedButton(onPressed: saveTemplate, child: const Text("Save")),
        ElevatedButton(onPressed: addAnswer, child: const Text("Add")),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        ElevatedButton(onPressed: widget.template == null ? null : deleteTemplate, child: const Text("Delete")),
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
                  child: MarkdownBody(
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
                )
              ],
            ),

            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.source?.join('') ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Checkbox(
                    value: task.isCheckSource,
                    onChanged: (checked) {
                      setState(() {
                        tasks[taskIndex] = task.copyWith(isCheckSource: checked ?? false);
                      });
                    },
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
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.answer?.join('') ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Checkbox(
                    value: task.isCheckAnswer,
                    onChanged: (checked) {
                      setState(() {
                        tasks[taskIndex] = task.copyWith(isCheckAnswer: checked ?? false);
                      });
                    },
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
