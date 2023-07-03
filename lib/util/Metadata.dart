import 'dart:convert';
import 'MetaKeyword.dart';

class MetaData {
  static String _trimming(String str, [String? chars]) {
    RegExp pattern = (chars != null)
        ? RegExp('^[$chars]+|[$chars]+\$')
        : RegExp(r'^\s+|\s+$');
    return str.replaceAll(pattern, '');
  }

  static String _preprocessing(String str) {
    int checkIndex = str.indexOf("Model:");
    if (checkIndex == -1) {
      return "";
    }

    StringBuffer sb = StringBuffer();
    String prevChar = "";
    for (int i = 0; i < str.length; i++) {
      var char = str[i];
      if (char == "u00A0") {
        sb.write(' ');
      } else if (char == "\n") {
        if (prevChar != "\n") {
          sb.write('\n');
        }
      } else {
        sb.write(char);
      }

      prevChar = char;
    }

    var result = sb.toString();
    return result;
  }

  String _metaText = "";
  final Map<String, String> _metaTable = <String, String>{};

  void fromJson(String jsonText) {
    List<dynamic> jsonData = jsonDecode(jsonText);
    Map<String, dynamic> firstData = jsonData[0] as Map<String, dynamic>;
    _metaTable.clear();

    var imageWidth = firstData["ImageWidth"];
    var imageHeight = firstData["ImageHeight"];

    if (imageWidth != null) {
      _metaTable["ImageWidth"] = imageWidth.toString();
    }
    if (imageHeight != null) {
      _metaTable["ImageHeight"] = imageHeight.toString();
    }

    if (firstData.containsKey("Parameters")) {
      _metaText = _preprocessing(firstData["Parameters"]!);
      _parseParameter();
    } else if (firstData.containsKey("UserComment")) {
      _metaText = _preprocessing(firstData["UserComment"]!);
      _parseParameter();
    }
  }

  void _addTable(String k, String v) {
    v = _trimming(v, " \t\n\r");
    _metaTable[k] = v;
  }

  bool _addParam(String param, {int nextIdx = -1}) {
    String keyword = "$param:";
    int idx = _metaText.indexOf(keyword);
    if (idx == -1) {
      return false;
    }

    int paramIdx = idx + keyword.length;
    if (nextIdx == -1) {
      int ppIdx = paramIdx;
      while (ppIdx < _metaText.length && _metaText[ppIdx] == ' ') {
        ppIdx++;
      }

      if (_metaText[ppIdx] == '\"') {
        nextIdx = _metaText.indexOf('\"', ppIdx + 1);
      } else {
        nextIdx = _metaText.indexOf(',', ppIdx);
      }

      if (nextIdx == -1) nextIdx = _metaText.length;
    }

    String parseParam = _metaText.substring(paramIdx, nextIdx);
    _addTable(param, parseParam);
    return true;
  }

  void _parseParameter() {
    if (_metaText.isEmpty) return;

    int promptEndIndex = _metaText.indexOf(MetaKeyword.Negative_prompt);
    if (promptEndIndex == -1) {
      var index = _metaText.indexOf(":");
      if (index != -1) index = _metaText.length;
      for (var i = index - 1; i >= 0; i--) {
        if (_metaText[i] == '\n') {
          promptEndIndex = i;
          break;
        }
      }
    }

    if (_metaText.startsWith(MetaKeyword.Parameters)) {
      _addTable(MetaKeyword.Parameters,
          _metaText.substring(MetaKeyword.Parameters.length, promptEndIndex));
    } else {
      _addTable(MetaKeyword.Parameters, _metaText.substring(0, promptEndIndex));
    }

    int negativePromptEndIndex = _metaText.indexOf("\n", promptEndIndex + 1);
    _addParam(MetaKeyword.Negative_prompt, nextIdx: negativePromptEndIndex);

    _addParam(MetaKeyword.Steps);
    _addParam(MetaKeyword.Sampler);
    _addParam(MetaKeyword.CFG_scale);
    _addParam(MetaKeyword.Size);
    _addParam(MetaKeyword.Seed);
    _addParam(MetaKeyword.Model_hash);
    _addParam(MetaKeyword.Model);
    _addParam(MetaKeyword.Clipskip);
    _addParam(MetaKeyword.ControlNet);
    _addParam(MetaKeyword.ControlNet0);
    _addParam(MetaKeyword.ControlNet1);

    return;
  }

  void clear() {
    _metaText = "";
    _metaTable.clear();
  }

  String toString() {
    StringBuffer sb = StringBuffer();
    if (_metaTable.isNotEmpty) {
      sb.writeln("\"meta\" : {");
      _metaTable.forEach((key, value) {
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
