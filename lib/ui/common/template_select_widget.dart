import 'dart:io';

import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/state/templates_provider.dart';
import 'package:auto_ipynb/ui/common/delete_button.dart';
import 'package:auto_ipynb/ui/common/exception_widget.dart';
import 'package:auto_ipynb/ui/screens/template_create_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateSelectWidget extends ConsumerStatefulWidget {
  final ValueSetter<Template?> onTemplateSelected;

  const TemplateSelectWidget({super.key, required this.onTemplateSelected});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TemplateSelectWidgetState();
}

class _TemplateSelectWidgetState extends ConsumerState<TemplateSelectWidget> {
  Template? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    final templatesValue = ref.watch(templatesProvider);
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: templatesValue.when(
          data: _getTemplatesWrap,
          error: (object, trace) => ExceptionWidget(object, trace),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _getTemplatesWrap(List<Template> templates) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: templates.map(_getTemplateCard).toList(),
          ),
          ElevatedButton(
            onPressed: createTemplateModal,
            child: const Text('Create new'),
          ),
        ],
      ),
    );
  }

  Widget _getTemplateCard(Template template) {
    return Card(
      surfaceTintColor: Colors.lightBlueAccent,
      child: SizedBox(
        width: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Radio(
                value: template,
                groupValue: _selectedTemplate,
                onChanged: (Template? tt) {
                  setState(() {
                    _selectedTemplate = tt;
                  });
                  widget.onTemplateSelected(_selectedTemplate);
                },
              ),
            ),
            Text(template.name),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplateCreateEditScreen(
                              template: template,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit)),
                DeleteButton(
                  onDelete: () {
                    ref.read(templatesProvider.notifier).delete(template);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void createTemplateModal() async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Add new template"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: createEmptyTemplate,
              child: const Text('Empty'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: createFileTemplate,
              child: const Text('From file'),
            ),
          ],
        ),
      );
    }
  }

  void createEmptyTemplate() async {
    Navigator.of(context).pop();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TemplateCreateEditScreen(),
        ),
      );
    }
  }

  void createFileTemplate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ipynb'],
    );
    if (result != null) {
      var f = File(result.files.single.path!);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TemplateCreateEditScreen(
                    fileTemplate: Template.fromFile(f),
                  )),
        );
      }
    }
  }
}
