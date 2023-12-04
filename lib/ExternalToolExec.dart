import 'dart:convert';
import 'dart:io';

import 'package:simple_logger/simple_logger.dart';

class ExternalToolExec {
  static Future<bool> openShell(String targetPath) async {
    var logger = SimpleLogger();

    try {
      if (Platform.isWindows) {
        ProcessResult result = await Process.run('explorer.exe ', [
          '/select,',
          targetPath,
        ]);
      } else if (Platform.isMacOS) {
        // TODO : open -R your-file-path
      }
    } on Exception {
      logger.log(Level.WARNING, "Failed to openShell");
      return false;
    }

    return true;
  }
}
