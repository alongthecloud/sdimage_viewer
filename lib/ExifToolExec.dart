import 'dart:convert';
import 'dart:io';

import 'package:simple_logger/simple_logger.dart';

class ExifToolExec {
  static String ExifToolPath_win = "exiftool.exe";
  static String ExifToolPath_unix = "exiftool";

  static Future<String?> run(String imagePath) async {
    var toolPath = Platform.isWindows ? ExifToolPath_win : ExifToolPath_unix;

    var logger = SimpleLogger();
    try {
      ProcessResult result = await Process.run(toolPath, [imagePath, '-j'],
          stdoutEncoding: utf8, stderrEncoding: utf8, runInShell: true);

      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        logger.info(result.stdout.toString());
        logger.log(Level.WARNING, result.stderr.toString());
      }
    } on Exception {
      logger.log(Level.WARNING, "Failed to run $toolPath.");
      return null;
    }

    return null;
  }
}
