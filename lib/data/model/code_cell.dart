import 'cell.dart';
import 'cell_output.dart';

class CodeCell extends Cell {
  final int executionCount;
  final List<CellOutput> outputs;

  CodeCell({
    required super.metadata,
    required super.source,
    required this.executionCount,
    required this.outputs,
  }) : super(type: CellType.code);
}
