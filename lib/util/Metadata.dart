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
