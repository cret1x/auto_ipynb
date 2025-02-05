enum CellOutputType {
  stream,
  display,
  execute,
  error,
}

class CellOutput {
  final CellOutputType type;

  CellOutput({required this.type});
}
