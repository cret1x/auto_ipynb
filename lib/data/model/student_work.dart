import 'package:auto_ipynb/data/model/python_task.dart';

enum RunStatus {
  pending,
  running,
  success,
  checked,
  fail,
}

class StudentWork {
  final String notebookFilename;
  final List<PythonTask> tasks;
  final RunStatus status;

  StudentWork({
    required this.notebookFilename,
    required this.tasks,
    required this.status,
  });

  StudentWork changeStatus(RunStatus newStatus) => StudentWork(
        notebookFilename: notebookFilename,
        tasks: tasks,
        status: newStatus,
      );

  factory StudentWork.fromJson(Map<String, dynamic> json) {
    return StudentWork(
      notebookFilename: json['notebook'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => PythonTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: RunStatus.values.byName(json['status']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'notebook': notebookFilename,
        'tasks': tasks,
        'status': status.name,
      };
}
