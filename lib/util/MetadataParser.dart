import 'MetaKeyword.dart';

class _StringUtils {
  // string utilities
  static String trimming(String str, [String? chars]) {
    RegExp pattern = (chars != null)
        ? RegExp('^[$chars]+|[$chars]+\$')
        : RegExp(r'^\s+|\s+$');
    return str.replaceAll(pattern, '');
  }
}

abstract class MetadataParser {
  late Map<String, String> _metaTable;
  MetadataParser(this._metaTable);

  void addMetaTable(String key, String value) {
    _metaTable[key] = value;
  }

  bool fromMetaText(Map<String, dynamic> firstData);
}

class MetadataParserInvokeAI extends MetadataParser {
  MetadataParserInvokeAI(super._metaTable);

  bool _addParam(Map<String, dynamic> firstData, String param) {
    String? key = MetaKeywordTable.InvokeAI[param];
    if (key == null) return false;

    addMetaTable(param, firstData[key].toString());
    return true;
  }

  @override
  bool fromMetaText(Map<String, dynamic> firstData) {
    bool result = false;
    if (_addParam(firstData, MetaKeyword.Prompt)) {
      result = true;
    }

    _addParam(firstData, MetaKeyword.Negative_prompt);
    _addParam(firstData, MetaKeyword.Steps);
    _addParam(firstData, MetaKeyword.Sampler);
    _addParam(firstData, MetaKeyword.CFG_scale);
    _addParam(firstData, MetaKeyword.Seed);
    _addParam(firstData, MetaKeyword.Model);
    _addParam(firstData, MetaKeyword.Clipskip);

    return result;
  }
}

class MetadataParserA1111 extends MetadataParser {
  MetadataParserA1111(super._metaTable);

  String _preprocessing(String str) {
    var modelKeyword = MetaKeywordTable.A1111[MetaKeyword.Model];
    int checkIndex = str.indexOf(modelKeyword!);
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

  @override
  bool fromMetaText(Map<String, dynamic> firstData) {
    String metaText = "";

    if (firstData.containsKey("Parameters")) {
      metaText = _preprocessing(firstData["Parameters"]!);
      _parseParameter(metaText);
      return true;
    } else if (firstData.containsKey("UserComment")) {
      metaText = _preprocessing(firstData["UserComment"]!);
      _parseParameter(metaText);
      return true;
    } else {
      return false;
    }
  }

  void _addTable(String k, String v) {
    v = _StringUtils.trimming(v, " \t\n\r");
    addMetaTable(k, v);
  }

  bool _addParam(String metaText, String param,
      {String? keyword, int nextIdx = -1}) {
    keyword ??= MetaKeywordTable.A1111[param];
    if (keyword == null) {
      return false;
    }

    int idx = metaText.indexOf(keyword);
    if (idx == -1) {
      return false;
    }

    int paramIdx = idx + keyword.length;
    if (nextIdx == -1) {
      int ppIdx = paramIdx;
      while (ppIdx < metaText.length && metaText[ppIdx] == ' ') {
        ppIdx++;
      }

      if (metaText[ppIdx] == '\"') {
        nextIdx = metaText.indexOf('"', ppIdx + 1);
      } else {
        nextIdx = metaText.indexOf(',', ppIdx);
      }

      if (nextIdx == -1) nextIdx = metaText.length;
    }

    String parseParam = metaText.substring(paramIdx, nextIdx);
    _addTable(param, parseParam);
    return true;
  }

  int _findEndOf(String metaText, int startIdx, String nextKey) {
    String? nextKeyword = MetaKeywordTable.A1111[nextKey];

    int endIndex = nextKeyword == null ? -1 : metaText.indexOf(nextKeyword);
    if (endIndex == -1) {
      var index = metaText.indexOf(":", startIdx);
      if (index == -1) index = metaText.length;

      for (var i = index - 1; i >= startIdx; i--) {
        if (metaText[i] == '\n') {
          endIndex = i;
          break;
        }
      }
    }

    return endIndex;
  }

  void _parseParameter(String metaText) {
    if (metaText.isEmpty) return;

    var promptEndIndex = _findEndOf(metaText, 0, MetaKeyword.Negative_prompt);
    if (promptEndIndex == -1) return;

    String? promptKeyword = MetaKeywordTable.A1111[MetaKeyword.Prompt];
    if (promptKeyword == null) {
      return;
    }

    if (metaText.startsWith(promptKeyword)) {
      _addTable(MetaKeyword.Prompt,
          metaText.substring(promptKeyword.length, promptEndIndex));
    } else {
      _addTable(MetaKeyword.Prompt, metaText.substring(0, promptEndIndex));
    }

    int negativePromptEndIndex =
        _findEndOf(metaText, promptEndIndex, MetaKeyword.Steps);

    _addParam(metaText, MetaKeyword.Negative_prompt,
        nextIdx: negativePromptEndIndex);

    _addParam(metaText, MetaKeyword.Steps);
    _addParam(metaText, MetaKeyword.Sampler);
    _addParam(metaText, MetaKeyword.CFG_scale);
    _addParam(metaText, MetaKeyword.Size);
    _addParam(metaText, MetaKeyword.Seed);
    _addParam(metaText, MetaKeyword.Model_hash);
    _addParam(metaText, MetaKeyword.Model);
    _addParam(metaText, MetaKeyword.Clipskip);
    if (!_addParam(metaText, MetaKeyword.ControlNet, keyword: "ControlNet:")) {
      _addParam(metaText, MetaKeyword.ControlNet, keyword: "ControlNet 0:");
    }

    return;
  }
}
