import 'dart:convert';
import 'dart:io';

import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/util/directory.dart';

class TemplateRepository {
  static Future<void> saveTemplates(List<String> templateIds, Template template, {bool isDelete = false}) async {
    final directory = await getAppDirectory();
    final templateDirectory = await getTemplatesDirectory();
    final templatesListFile = File('${directory.path}/templates.json');
    final templateFile = File('${templateDirectory.path}/${template.id}.json');

    // Save templates list
    final templateListJsonString = jsonEncode(templateIds);
    await templatesListFile.writeAsString(templateListJsonString);
    print('Templates list saved to: ${templatesListFile.path}');
    // Save template
    if (isDelete) {
      await templateFile.delete();
      print('Template deleted');
      return;
    }
    final templateJson = jsonEncode(template.toJson());
    await templateFile.writeAsString(templateJson);
    print('Template saved to: ${templateFile.path}');
  }

  static Future<List<Template>> loadTemplatesFromFile() async {
    // Get the documents directory
    final directory = await getAppDirectory();
    final templateDirectory = await getTemplatesDirectory();
    final templateListFile = File('${directory.path}/templates.json');

    // Check if the file exists
    if (await templateListFile.exists()) {
      // Read the file
      final templateListJsonString = await templateListFile.readAsString();
      // Convert JSON back to templates
      final List<dynamic> templateIds = jsonDecode(templateListJsonString);
      final List<dynamic> templates = [];
      for (var tid in templateIds) {
        final templateFile = File('${templateDirectory.path}/$tid.json');
        if (templateFile.existsSync()) {
          final templateJsonString = await templateFile.readAsString();
          templates.add(jsonDecode(templateJsonString));
        }
      }
      return templates.map((json) => Template.fromJson(json)).toList();
    } else {
      print('No templates file found.');
      return []; // Return an empty list if the file doesn't exist
    }
  }
}
