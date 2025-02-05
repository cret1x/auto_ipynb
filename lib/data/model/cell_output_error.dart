import 'cell_output.dart';

class CellOutputError extends CellOutput {
  final String eName;
  final String eValue;
  final List<String> traceback;

  CellOutputError({
    required this.eName,
    required this.eValue,
    required this.traceback,
  }) : super(type: CellOutputType.error);
}
