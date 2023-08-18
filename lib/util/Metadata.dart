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

    var imageWidth = firstData["ImageWidth"];
    var imageHeight = firstData["ImageHeight"];

    if (imageWidth != null) {
      _metaTable["ImageWidth"] = imageWidth.toString();
    }
    if (imageHeight != null) {
      _metaTable["ImageHeight"] = imageHeight.toString();
    }

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
