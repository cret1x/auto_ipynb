import 'dart:async';
import 'dart:io';

import 'package:auto_ipynb/data/model/template.dart';
import 'package:auto_ipynb/data/repository/template_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplatesNotifier extends AsyncNotifier<List<Template>> {
  @override
  Future<List<Template>> build() async {
    return TemplateRepository.loadTemplatesFromFile();
  }

  Future<void> save(Template template) async {
    if (state.hasValue) {
      var templates = state.value!;
      if (templates.contains(template)) {
        final modifiedTemplates = [
          for (final t in templates)
            if (t.id == template.id) template else t
        ];
        await TemplateRepository.saveTemplates(modifiedTemplates.map((t) => t.id).toList(), template);
        state = AsyncValue.data(modifiedTemplates);
      } else {
        final modifiedTemplates = [...templates, template];
        await TemplateRepository.saveTemplates(modifiedTemplates.map((t) => t.id).toList(), template);
        state = AsyncValue.data(modifiedTemplates);
      }
    }
  }

  Future<void> delete(Template template) async {
    if (state.hasValue) {
      final templates = state.value!.where((t) => t.id != template.id).toList();
      await TemplateRepository.saveTemplates(templates.map((t) => t.id).toList(), template, isDelete: true);
      state = AsyncValue.data(templates);
    }
  }
}

final templatesProvider = AsyncNotifierProvider<TemplatesNotifier, List<Template>>(TemplatesNotifier.new);
