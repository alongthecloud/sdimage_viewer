import 'dart:convert';
import 'package:simple_logger/simple_logger.dart';
import 'MetadataParser.dart';

class MetaData {
  late final Map<String, String> _metaTable = {};
  String imageType = "";

  void clear() {
    _metaTable.clear();
  }

  void fromJson(String jsonText) {
    var logger = SimpleLogger();

    clear();

    List<dynamic> jsonData = jsonDecode(jsonText);
    Map<String, dynamic> firstData = jsonData[0] as Map<String, dynamic>;

    imageType = "";

    const String InvokeAIMetaKey = "Invokeai_metadata";
    if (firstData.containsKey(InvokeAIMetaKey)) {
      String metaText = firstData[InvokeAIMetaKey];
      var parser = MetadataParserInvokeAI(_metaTable);

      Map<String, dynamic> metaData =
          jsonDecode(metaText) as Map<String, dynamic>;
      if (parser.fromMetaText(metaData)) {
        imageType = "InvokeAI";
      }
    } else if (firstData.containsKey("Workflow")) {
      String metaText = firstData["Workflow"];
      Map<String, dynamic> workflow =
          jsonDecode(metaText) as Map<String, dynamic>;

      if (workflow.containsKey("nodes")) {
        try {
          var nodeNames = [];
          var nodes = workflow["nodes"];
          for (var n in nodes) {
            var typeName = n["type"] as String;
            if (typeName.toLowerCase() != "reroute") {
              if (!nodeNames.contains(typeName)) {
                nodeNames.add(typeName);
              }
            }

            if (typeName.toLowerCase().contains("cliptext")) {
              var values = n["widgets_values"];
              if (values is List) {
                const String CLIP = "Clip";
                var clipValue = _metaTable.containsKey(CLIP)
                    ? "${_metaTable[CLIP]}\n----\n"
                    : "";
                for (var v in values) {
                  clipValue += v.toString();
                  clipValue += "\n";
                }

                _metaTable[CLIP] = clipValue;
              }
            }
          }

          if (nodeNames.isNotEmpty) {
            nodeNames.sort();
            _metaTable["Nodes"] = nodeNames.toString();
          }
          imageType = "ComfyUI";
        } catch (Exception) {}
      }
    } else {
      var parser = MetadataParserA1111(_metaTable);
      if (parser.fromMetaText(firstData)) {
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
