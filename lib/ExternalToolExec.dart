import 'dart:io';

import 'package:simple_logger/simple_logger.dart';

class ExternalToolExec {
  static Future<bool> openShell(String targetPath) async {
    var logger = SimpleLogger();

    try {
      if (Platform.isWindows) {
        // explorer /select file-path
        await Process.run('explorer.exe ', [
          '/select,',
          targetPath,
        ]);
      } else if (Platform.isMacOS) {
        // open -R file-path
        var Result = await Process.run('open', [
          '-R',
          targetPath,
        ]);

        logger.info(Result.exitCode);
      }
    } catch (e) {
      logger.log(Level.WARNING, "Failed to openShell : $e");
      return false;
    }

    return true;
  }
}
