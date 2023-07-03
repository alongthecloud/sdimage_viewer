import 'dart:io';
import 'package:path/path.dart' as path;

class PathUtil {
  static bool _isHiddenName(String name) {
    if (name.startsWith(".")) {
      return true;
    } else {
      return false;
    }
  }

  // 디렉토리 목록을 traversal 해서 가져오기
  static List<Directory> getDirectoriesFromDirectory(
      Directory targetDir, bool recursive) {
    List<FileSystemEntity> files = targetDir.listSync(recursive: recursive);

    List<Directory> directories = [];
    for (var fileEntity in files) {
      if (fileEntity is! Directory) continue;

      var dirBasename = path.basename(fileEntity.path);
      if (_isHiddenName(dirBasename)) continue;

      directories.add(fileEntity);
    }

    return directories;
  }

  static List<Directory> getSpecificDirectoriesFromDirectory(
      Directory targetDir, bool recursive) {
    List<FileSystemEntity> files = targetDir.listSync(recursive: recursive);

    List<Directory> directories = [];
    for (var fileEntity in files) {
      if (fileEntity is! Directory) continue;

      var dirBasename = path.basename(fileEntity.path);
      if (_isHiddenName(dirBasename)) continue;

      directories.add(fileEntity);
    }

    return directories;
  }

  // filter 함수에 맞는 파일만 가져오기
  static List<FileSystemEntity> getSpecificFilesFromDirectory(
      Directory targetDirectory, bool recursive, bool Function(String) filter) {
    List<FileSystemEntity> files =
        targetDirectory.listSync(recursive: recursive);

    List<FileSystemEntity> results = [];
    for (var fileEntity in files) {
      var dirBasename = path.basename(fileEntity.path);
      if (_isHiddenName(dirBasename)) continue;

      if (fileEntity is! Directory) {
        // 파일만 ...
        bool isOk = filter(fileEntity.path);
        if (isOk) {
          results.add(fileEntity);
        }
      }
    }

    return results;
  }
}
