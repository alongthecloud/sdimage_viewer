import 'dart:convert';
import 'MetadataParser.dart';

class MetaData {
  late final Map<String, String> _metaTable = {};
  String imageType = "";

  void clear() {
    _metaTable.clear();
  }

  void fromJson(String jsonText) {
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
    } else {
      var parser = MetadataParserA1111(_metaTable);
      if (parser.fromMetaText(firstData)) {
        imageType = "A1111";
      }
    }
  }

  String? toJson() {
    // _metaTable to json
    String jsonText = jsonEncode(_metaTable);
    return jsonText;
  }

  String toString() {
    final metaTable = _metaTable;
    StringBuffer sb = StringBuffer();
    if (metaTable.isNotEmpty) {
      sb.writeln("\"meta\" : {");
      metaTable.forEach((key, value) {
        sb.writeln("\"$key\" : $value");
      });
      sb.writeln("}");
    }
    return sb.toString();
  }

  Map<String, String> getMetaTable() {
    return _metaTable;
  }
}
