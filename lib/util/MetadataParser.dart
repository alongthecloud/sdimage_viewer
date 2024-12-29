import 'package:path/path.dart' as path;

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
  Map<String, String>? fromMetaText(Map<String, dynamic> firstData);
}
