import 'cell_output.dart';
import 'cell_output_data.dart';

class CellOutputExecuteResult extends CellOutput {
  final Map<String, dynamic> metadata;
  final int executionCount;
  final CellOutputDataText? textData;
  final CellOutputDataImage? imageData;
  final CellOutputDataJson? jsonData;
  final CellOutputDataHtml? htmlData;

  CellOutputExecuteResult({
    required this.executionCount,
    required this.metadata,
    this.textData,
    this.imageData,
    this.jsonData,
    this.htmlData,
  }) : super(type: CellOutputType.execute);
}
