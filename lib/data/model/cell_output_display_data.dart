import 'cell_output.dart';
import 'cell_output_data.dart';

class CellOutputDisplayData extends CellOutput {
  final Map<String, dynamic> metadata;
  final CellOutputDataText? textData;
  final CellOutputDataImage? imageData;
  final CellOutputDataJson? jsonData;
  final CellOutputDataHtml? htmlData;

  CellOutputDisplayData({
    required this.metadata,
    this.textData,
    this.imageData,
    this.jsonData,
    this.htmlData,
  }) : super(type: CellOutputType.display);
}
