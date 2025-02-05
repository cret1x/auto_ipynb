import 'package:auto_ipynb/data/model/cell.dart';

class MarkdownCell extends Cell {
  MarkdownCell({
    required super.metadata,
    required super.source,
  }) : super(type: CellType.markdown);
}
