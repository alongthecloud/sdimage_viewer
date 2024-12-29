import 'dart:core';
import 'package:simple_logger/simple_logger.dart';

import 'MetaKeyword.dart';
import 'MetadataParser.dart';

class MetadataParserA1111 extends MetadataParser {
  @override
  Map<String, String>? fromMetaText(Map<String, dynamic> firstData) {
    String metaText = "";

    if (firstData.containsKey("Parameters")) {
      metaText = _preprocessing(firstData["Parameters"]!);
    } else if (firstData.containsKey("UserComment")) {
      metaText = _preprocessing(firstData["UserComment"]!);
    } else {
      return null;
    }

    final Map<String, dynamic> result = _parseKeywordFromText(metaText);
    if (result.isEmpty) return null;

    Map<String, String> metaTable = {};
    for (final String key in MetaKeywordTable.A1111) {
      if (result.containsKey(key)) {
        final value = result[key];
        String text = value == null ? '' : value.toString();
        if (key.startsWith('ControlNet') && value != null) {
          final match = RegExp(r"Model:\s*([^,]+)").firstMatch(text);
          if (match != null) {
            text = match.group(1)!.trim();
          }
        }

        metaTable[key] = text;
      }
    }

    return metaTable;
  }

  String _preprocessing(String text) {
    text = text.replaceAll('\u00A0', ' ');
    text = text.replaceAll('\\n', '\n');
    return text;
  }

  Map<String, String> _parseKeywordFromText(String text) {
    final pattern = RegExp(r'([A-Z][a-zA-Z\s0-9]*):\s*');
    List<Map<String, dynamic>> keywordIndexes = [];

    // Initialize with Prompt
    keywordIndexes.add({'keyword': 'Prompt', 'start': 0, 'end': -1});

    int index = 0;
    int length = text.length;

    while (index < length) {
      Match? m = pattern.firstMatch(text.substring(index));
      if (m == null) break;

      String keyword = m.group(1) ?? '';
      int start = index + m.start;
      int end = index + m.end;

      // Update previous keyword's end position
      keywordIndexes.last['end'] = start;

      // Add new keyword
      keywordIndexes.add({'keyword': keyword, 'start': end, 'end': -1});

      // Handle special cases for ControlNet and Lora hashes
      if (keyword.startsWith('ControlNet') ||
          keyword.startsWith('Lora hashes')) {
        final quotePattern = RegExp(r'"([^"]*)"');
        Match? quoteMatch = quotePattern.firstMatch(text.substring(end));

        if (quoteMatch != null) {
          int quoteEnd = end + quoteMatch.end;
          index = quoteEnd;
          continue;
        }
      }

      index = end;
    }

    // Set the end position for the last keyword
    if (keywordIndexes.isNotEmpty) {
      keywordIndexes.last['end'] = text.length;
    }

    // Create result map
    Map<String, String> result = {};

    for (var ki in keywordIndexes) {
      String keyword = ki['keyword'];
      // assuming a1111Keywords is defined elsewhere
      if (MetaKeywordTable.A1111.contains(keyword)) {
        String value = text
            .substring(ki['start'], ki['end'])
            .replaceAll(RegExp(r'[,\s\n\r\t]+$'), '');
        result[keyword] = value;
      }
    }

    return result;
  }
}
