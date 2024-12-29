import 'package:simple_logger/simple_logger.dart';

import 'MetaKeyword.dart';
import 'MetadataParser.dart';

class MetadataParserInvokeAI extends MetadataParser {
  @override
  Map<String, String>? fromMetaText(Map<String, dynamic> firstData) {
    final Map<String, String> metaTable = {};
    bool result = false;
    for (final String key in MetaKeywordTable.InvokeAI) {
      if (firstData.containsKey(key)) {
        final value = firstData[key];
        metaTable[key] = value == null ? '' : value!.toString();
        result = true;
      }
    }

    return result ? metaTable : null;
  }
}
