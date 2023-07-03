import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_logger/simple_logger.dart';

class Util {
  static String dateTimeToString(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy년MM월dd일 hh시mm분ss초');
    return formatter.format(date);
  }

  static String dateToString(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy년MM월dd일');
    return formatter.format(date);
  }

  static String timeToString(DateTime date) {
    final DateFormat formatter = DateFormat('HH시mm분ss초');
    return formatter.format(date);
  }

  static Widget basicHelloWorldWidget(
      BuildContext context, List<String> texts) {
    return ListView.builder(
      itemCount: texts.length,
      itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(4), child: Text(texts[index])),
    );
  }

  // Json 을 읽기
  static Object? loadJsonFromFile(String filepath) {
    var fp = File(filepath);
    if (!fp.existsSync()) {
      return null;
    }

    String text = fp.readAsStringSync();
    dynamic json = jsonDecode(text);

    return json;
  }

  // Json을 쓰기
  static Future<bool> saveJsonTextToFile(dynamic json, String filepath,
      {bool overwrite = true, bool pretty = false}) async {
    var fp = File(filepath);
    if (fp.existsSync() && overwrite == false) {
      return false;
    }

    String jsonText;
    if (kDebugMode || pretty) {
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      jsonText = encoder.convert(json);
    } else {
      jsonText = jsonEncode(json);
    }

    await fp.writeAsString(jsonText);

    var logger = SimpleLogger();
    logger.info("${fp.path} saved");
    return true;
  }
}
