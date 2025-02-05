class CellOutputData {
  final String mimeType;

  CellOutputData(this.mimeType);
}

class CellOutputDataText extends CellOutputData {
  final List<String> data;

  CellOutputDataText({required this.data}) : super("text/plain");
}

class CellOutputDataImage extends CellOutputData {
  final List<String> data;

  CellOutputDataImage({required this.data}) : super("image/png");
}

class CellOutputDataJson extends CellOutputData {
  final Map<String, dynamic> data;

  CellOutputDataJson({required this.data}) : super("application/json");
}

class CellOutputDataHtml extends CellOutputData {
  final List<String> data;

  CellOutputDataHtml({required this.data}) : super("text/html");
}
