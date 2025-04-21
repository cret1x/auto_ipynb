import 'package:auto_ipynb/data/model/cell.dart';
import 'package:auto_ipynb/data/model/cell_output.dart';
import 'package:auto_ipynb/data/model/cell_output_data.dart';
import 'package:auto_ipynb/data/model/cell_output_display_data.dart';
import 'package:auto_ipynb/data/model/cell_output_error.dart';
import 'package:auto_ipynb/data/model/cell_output_execute_result.dart';
import 'package:auto_ipynb/data/model/cell_output_stream.dart';
import 'package:auto_ipynb/data/model/code_cell.dart';
import 'package:auto_ipynb/data/model/markdown_cell.dart';
import 'package:auto_ipynb/data/model/notebook.dart';
import 'package:auto_ipynb/data/model/python_task.dart';

class NbParser {
  static List<PythonTask> getTasksFromNotebook(Notebook nb) {
    List<PythonTask> tasks = [];
    var currTask = PythonTask(
      description: [],
      source: [],
      answer: [],
      images: [],
      isCheckSource: false,
      isCheckAnswer: false,
      isCheckPlag: false,
      scorePoints: 0,
    );
    for (var cell in nb.cells) {
      if (cell.type == CellType.markdown) {
        currTask = currTask.copyWith(description: (cell as MarkdownCell).source);
      } else if (cell.type == CellType.code) {
        currTask = currTask.copyWith(
          source: (cell as CodeCell).source,
          answer: cell.outputs
              .where((o) => o.type == CellOutputType.execute)
              .map((o) => o as CellOutputExecuteResult)
              .where((o) => o.textData != null)
              .map((o) => o.textData)
              .map((o) => o!.data)
              .expand((o) => o)
              .toList(),
          images: cell.outputs
              .where((o) => o.type == CellOutputType.display)
              .map((o) => o as CellOutputDisplayData)
              .where((o) => o.imageData != null)
              .map((o) => o.imageData)
              .map((o) => o!.data)
              .expand((o) => o)
              .map((o) => o.replaceAll(RegExp(r'\s+'), ''))
              .toList(),
        );
        tasks.add(currTask);
        currTask = PythonTask(
          description: [],
          source: [],
          answer: [],
          isCheckSource: false,
          isCheckAnswer: false,
          isCheckPlag: false,
          scorePoints: 0,
        );
      }
    }
    return tasks;
  }

  static Notebook parseJsonToNotebook(String filename, Map<String, dynamic> json) {
    var metadata = json['metadata'] ?? {};
    var rawCells = List<Map<String, dynamic>>.from(json['cells'] ?? []);
    var cells = <Cell>[];
    for (var cell in rawCells) {
      var cellType = cell['cell_type'] ?? '';
      switch (cellType) {
        case "markdown":
          {
            Map<String, dynamic> cellMetadata = cell['metadata'] ?? {};
            var source = List<String>.from(cell['source']);
            cells.add(MarkdownCell(metadata: cellMetadata, source: source));
          }
        case "code":
          {
            cells.add(parseJsonToCodeCell(cell));
          }
        default:
          {
            print("Unknown cell type");
          }
      }
    }
    return Notebook(filename: filename, cells: cells, metadata: metadata);
  }

  static CodeCell parseJsonToCodeCell(Map<String, dynamic> cell) {
    Map<String, dynamic> metadata = cell['metadata'] ?? {};
    int executionCount = cell['execution_count'] ?? 0;
    var source = List<String>.from(cell['source']);
    var rawOutputs = List<Map<String, dynamic>>.from(cell['outputs'] ?? []);
    var outputs = <CellOutput>[];
    for (var output in rawOutputs) {
      var outputType = output['output_type'];
      switch (outputType) {
        case "stream":
          {
            var name = output['name'] ?? 'stdout';
            var text = List<String>.from(output['text'] ?? []);
            outputs.add(CellOutputStream(name: name, text: text));
          }
        case "display_data":
          {
            Map<String, dynamic> metadata = output['metadata'] ?? {};
            var rawText = output['data']['text/plain'];
            var rawImage = output['data']['image/png'];
            var rawJson = output['data']['application/json'];
            var rawHtml = output['data']['text/html'];
            CellOutputDataText? text = rawText != null ? CellOutputDataText(data: List<String>.from(rawText)) : null;
            CellOutputDataImage? img;
            if (rawImage != null) {
              if (rawImage is String) {
                img = CellOutputDataImage(data: [rawImage]);
              } else {
                img = CellOutputDataImage(data: List<String>.from(rawImage));
              }
            }
            CellOutputDataJson? json = rawJson != null ? CellOutputDataJson(data: rawJson) : null;
            CellOutputDataHtml? html = rawHtml != null ? CellOutputDataHtml(data: List<String>.from(rawHtml)) : null;
            outputs.add(CellOutputDisplayData(
              metadata: metadata,
              textData: text,
              imageData: img,
              jsonData: json,
              htmlData: html,
            ));
          }
        case "execute_result":
          {
            Map<String, dynamic> metadata = output['metadata'] ?? {};
            int oExecutionCount = output['execution_count'] ?? 0;
            var rawText = output['data']['text/plain'];
            var rawImage = output['data']['image/png'];
            var rawJson = output['data']['application/json'];
            var rawHtml = output['data']['text/html'];
            CellOutputDataText? text = rawText != null ? CellOutputDataText(data: List<String>.from(rawText)) : null;
            CellOutputDataImage? img = rawImage != null ? CellOutputDataImage(data: List<String>.from(rawImage)) : null;
            CellOutputDataJson? json = rawJson != null ? CellOutputDataJson(data: rawJson) : null;
            CellOutputDataHtml? html = rawHtml != null ? CellOutputDataHtml(data: List<String>.from(rawHtml)) : null;
            outputs.add(CellOutputExecuteResult(
              executionCount: oExecutionCount,
              metadata: metadata,
              textData: text,
              imageData: img,
              jsonData: json,
              htmlData: html,
            ));
          }
        case "error":
          {
            var eName = output['ename'] ?? '';
            var eValue = output['evalue'] ?? '';
            var traceback = List<String>.from(output['evalue'] ?? []);
            outputs.add(CellOutputError(
              eName: eName,
              eValue: eValue,
              traceback: traceback,
            ));
          }
      }
    }
    return CodeCell(metadata: metadata, source: source, executionCount: executionCount, outputs: outputs);
  }
}
