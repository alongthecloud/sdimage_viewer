import 'dart:collection';
import 'dart:convert';
import 'package:simple_logger/simple_logger.dart';
import 'MetadataParser.dart';
import 'MetadataParserInvokeAI.dart';
import 'MetadataParserA1111.dart';
import 'MetadataParserComfyUI.dart';

class MetaData {
  final Map<String, String> _metaTable = {};
  String imageType = "";

  void clear() {
    _metaTable.clear();
  }

  void fromJson(String jsonText) {
    clear();

    List<dynamic> jsonData = jsonDecode(jsonText);
    Map<String, dynamic> firstData = jsonData[0] as Map<String, dynamic>;

    imageType = "";
    _metaTable.clear();

    const String invokeaiMetadata = "Invokeai_metadata";
    if (firstData.containsKey(invokeaiMetadata)) {
      String metaText = firstData[invokeaiMetadata];
      var parser = MetadataParserInvokeAI();

      Map<String, dynamic> metaData =
          jsonDecode(metaText) as Map<String, dynamic>;
      var result = parser.fromMetaText(metaData);
      if (result != null) {
        _metaTable.addAll(result);
        imageType = "InvokeAI";
      }
    } else if (firstData.containsKey("Workflow")) {
      var parser = MetadataParserComfyUI();
      String metaText = firstData["Workflow"];
      Map<String, dynamic> workflow =
          jsonDecode(metaText) as Map<String, dynamic>;

      var result = parser.fromMetaText(workflow);
      if (result != null) {
        _metaTable.addAll(result);
        imageType = "ComfyUI";
      }
    } else {
      var parser = MetadataParserA1111();
      var result = parser.fromMetaText(firstData);
      if (result != null) {
        _metaTable.addAll(result);
        imageType = "A1111";
      }
    }
  }

  String? toJson(bool prettyPrint) {
    // _metaTable to json
    if (prettyPrint) {
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      String prettyprint = encoder.convert(_metaTable);
      return prettyprint;
    } else {
      String jsonText = jsonEncode(_metaTable);
      return jsonText;
    }
  }

  Map<String, String> getMetaTable() {
    return _metaTable;
  }
}
