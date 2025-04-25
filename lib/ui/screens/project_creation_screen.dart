import 'package:auto_ipynb/core/nb_env.dart';
import 'package:auto_ipynb/data/model/project.dart';
import 'package:auto_ipynb/state/project_creation_provider.dart';
import 'package:auto_ipynb/util/directory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectCreationScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectCreationScreen({super.key, required this.project});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends ConsumerState<ProjectCreationScreen> {
  String text = "";
  String errorText = "";

  @override
  void initState() {
    super.initState();
    seq().then((v) {
      Navigator.of(context).pop();
    }, onError: (err) {
      setState(() {
        text = "Ошибка при создании: ";
        errorText = err.toString();
      });
    });
  }

  Future<void> seq() async {

      setState(() {
        text = "Создание проекта...";
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        text = "Получение Python";
      });
      final python = await getPythonExe();
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        text = "Создание виртуального окружения...";
      });

      var (out, err) = await NbEnv.createPythonEnvironment(python, widget.project.rootPath);
      setState(() {
        text = "Установка библиотек...";
        errorText = err;
      });
      await NbEnv.installKernel(widget.project.rootPath, widget.project.id);


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 10,
              ),
              Text(text),
              const SizedBox(height: 10,),
              Text(errorText),
            ],
          ),
        ),
      ),
    );
  }
}
