import 'package:auto_ipynb/data/model/student_work.dart';
import 'package:auto_ipynb/data/model/template.dart';
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
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: widget.studentWork.tasks.length,
        itemBuilder: (context, index) => _getTaskCard(index),
      ),
    );
  }

  Widget _getTaskCard(int taskIndex) {
    final task = widget.studentWork.tasks[taskIndex];
    if (taskIndex >= widget.template.tasks.length) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No such task in template!"),
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
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                task.source?.join('') ?? '',
                style: const TextStyle(color: Colors.white),
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
                  color: Colors.green,
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
