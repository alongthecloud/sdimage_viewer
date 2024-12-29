import 'package:flutter/foundation.dart';
import 'package:simple_logger/simple_logger.dart';
import 'MetadataParser.dart';

class MetadataParserComfyUI extends MetadataParser {
  @override
  Map<String, String>? fromMetaText(Map<String, dynamic> firstData) {
    final logger = SimpleLogger();

    final workflow = firstData;
    Map<String, String> metatable = {};
    if (workflow.containsKey("nodes")) {
      try {
        var nodeNames = [];
        var nodes = workflow["nodes"];
        for (var n in nodes) {
          var typeName = n["type"].toString();
          var typeNameLower = typeName.toLowerCase();

          // reroute 는 포함하지 않는다
          if (typeNameLower != "reroute") {
            if (!nodeNames.contains(typeNameLower)) {
              nodeNames.add(typeName);
            }
          }
          // 수집 대상을 if 구문으로 분류
          if ((typeNameLower.contains("clip") &&
                  typeNameLower.contains("text")) ||
              (typeNameLower.contains("lora") &&
                  typeNameLower.contains("load")) ||
              (typeNameLower.contains("model") &&
                  typeNameLower.contains("load")) ||
              (typeNameLower.contains("load") &&
                  typeNameLower.contains("unet")) ||
              (typeNameLower.contains("checkpoint"))) {
            var values = n["widgets_values"];
            if (values is List) {
              var clipValue = metatable.containsKey(typeName)
                  ? metatable[typeName].toString()
                  : "";

              int i = 0;
              for (var v in values) {
                if (i != 0) clipValue += "\n";
                clipValue += v.toString();
                ++i;
              }

              clipValue += "\n";
              metatable[typeName] = clipValue;
            }
          }
        }

        if (nodeNames.isNotEmpty) {
          nodeNames.sort();
          metatable["nodes"] = nodeNames.toString();
        }

        var sortedByKeyMap = Map.fromEntries(metatable.entries.toList()
          ..sort((e1, e2) => e1.key.compareTo(e2.key)));
        metatable = sortedByKeyMap;

        return metatable;
      } on Exception {
        if (kDebugMode) {
          logger.log(Level.WARNING, "Failed to parse metadata.");
        }
      }
    }

    return null;
  }
}
