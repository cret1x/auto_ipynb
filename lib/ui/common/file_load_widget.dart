import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileLoadWidget extends StatefulWidget {
  final List<String> extensions;
  final ValueSetter<File> onFileSelected;
  final VoidCallback onFileCleared;

  const FileLoadWidget(
      {super.key, required this.extensions, required this.onFileSelected, required this.onFileCleared,});

  @override
  State<StatefulWidget> createState() => _FileLoadWidgetState();

}

class _FileLoadWidgetState extends State<FileLoadWidget> {
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: _selectedFile == null,
          child: ElevatedButton(
            onPressed: selectFile,
            child: Text("Select file"),
          ),
        ),
        Visibility(
          visible: _selectedFile != null,
          child: Text("Selected file: ${path.basename(_selectedFile?.path ?? "a.a")}"),
        ),
        Visibility(
          visible: _selectedFile != null,
          child: ElevatedButton(
            onPressed: clearFile,
            child: Text("Clear file"),
          ),
        ),
      ],
    );
  }

  void selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.extensions,
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      widget.onFileSelected(_selectedFile!);
    }
  }

  void clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

}