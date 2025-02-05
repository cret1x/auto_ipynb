enum CellType {
  generic,
  markdown,
  code,
}

class Cell {
  final CellType type;
  final Map<String, dynamic> metadata;
  final List<String> source;

  Cell({
    required this.type,
    required this.metadata,
    required this.source,
  });
}
