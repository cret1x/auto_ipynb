import 'package:json_annotation/json_annotation.dart';

import 'cell.dart';

class Notebook {
  final String filename;
  final List<Cell> cells;
  final Map<String, dynamic> metadata;

  Notebook({required this.filename, required this.cells, required this.metadata});
}