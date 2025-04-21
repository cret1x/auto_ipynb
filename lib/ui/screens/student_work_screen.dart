import 'dart:io';

import 'package:auto_ipynb/data/model/student_work.dart';
import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/ui/common/action_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentWorkScreen extends ConsumerStatefulWidget {
  final StudentWork studentWork;
  final Template template;

  const StudentWorkScreen({super.key, required this.studentWork, required this.template});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StudentWorkScreen();
}

class _StudentWorkScreen extends ConsumerState<StudentWorkScreen> {
  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.studentWork.notebookFilename),),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  ActionButton(onClick: createReport, child: const Text("Создать отчет проверки")),
                ],
              ),
              if (widget.studentWork.errors != null) Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text("Ошибки"),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.studentWork.errors!),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.studentWork.tasks.length,
                  itemBuilder: (context, index) => _getTaskCard(index),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createReport() async {
    String text = "";
    if (widget.studentWork.errors != null) {
      text += widget.studentWork.errors!;
      text += "\n\n";
    }
    for (int i = 0; i < widget.studentWork.tasks.length; i++) {
      var task = widget.studentWork.tasks[i];
      text += "Задание:\n";
      text += task.description?.join('') ?? '';
      text += "\n";
      text += "Исходный код:\n";
      text += task.source?.join('') ?? '';
      text += "\n";
      if (widget.template.tasks[i].isCheckSource) {
        text += "Правильный код:\n";
        text += widget.template.tasks[i].source?.join('') ?? '';
        text += "\n";
      }
      text += "Ответ:\n";
      text += task.answer?.join('') ?? '';
      text += "\n";
      if (widget.template.tasks[i].isCheckSource) {
        text += "Правильный ответ:\n";
        text += widget.template.tasks[i].source?.join('') ?? '';
        text += "\n";
      }
      text += "\n\n";
    }

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Выберите место сохранения файла:',
      fileName: '${widget.studentWork.notebookFilename}-report.log',
    );
    if (outputFile != null) {
      File file = File(outputFile);
      await file.writeAsString(text);
      print("File $outputFile exported successfully!");
    }
  }

  Widget _getTaskCard(int taskIndex) {
    final task = widget.studentWork.tasks[taskIndex];
    if (taskIndex >= widget.template.tasks.length) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Такого задания нет в шаблоне"),
        ),
      );
    }
    final question = widget.template.tasks[taskIndex];
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
                Visibility(
                  visible: task.isCheckAnswer || task.isCheckSource,
                  child: Flexible(
                    flex: 1,
                    child: Text(
                      "${task.scorePoints.toString()}/${question.scorePoints.toString()}",
                    ),
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
              child: Text(
                task.source?.join('') ?? '',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: question.isCheckSource,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  question.source?.join('') ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
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
              child: Text(
                task.answer?.join('') ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: question.isCheckAnswer,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  question.answer?.join('') ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
