import 'package:auto_ipynb/data/model/cell_output.dart';

class CellOutputStream extends CellOutput {
  final String name;
  final List<String> text;

  CellOutputStream({
    required this.name,
    required this.text,
  }) : super(type: CellOutputType.stream);
}
