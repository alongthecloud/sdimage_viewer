import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:sdimage_viewer/ExifToolExec.dart';
import 'package:simple_logger/simple_logger.dart';
import '../util/PathUtil.dart';
import '../util/Metadata.dart';
import 'ImageManager.dart';

class ViewerState {
  final ImageManager _imageManager = ImageManager();

  List<String> imageFileList = [];
  String curImagePath = "";

  int curImageIndex = -1;
  ui.Image? curImageData;
  MetaData curImageMetaData = MetaData();

  String getCurrentPositionText() {
    return "${curImageIndex + 1} / ${imageFileList.length}";
  }

  Future<bool> getNextImage() async {
    int nextIndex = (curImageIndex + 1);
    if (nextIndex < imageFileList.length) {
      curImageIndex = nextIndex;
      return await updateImage();
    } else {
      return false;
    }
  }

  Future<bool> getPreviousImage() async {
    int nextIndex = (curImageIndex - 1);
    if (nextIndex >= 0) {
      curImageIndex = nextIndex;
      return await updateImage();
    } else {
      return false;
    }
  }

  Future<bool> updateImage() async {
    if (curImagePath.isEmpty) return false;

    if (curImageIndex >= 0 && imageFileList.isNotEmpty) {
      curImagePath = imageFileList[curImageIndex];
    }

    var logger = SimpleLogger();
    logger.info(
        "Image: $curImagePath : $curImageIndex / ${imageFileList.length}");

    await Future.wait([
      ExifToolExec.run(curImagePath).then((String? value) {
        if (value != null) {
          curImageMetaData.fromJson(value);
        } else {
          curImageMetaData.clear();
        }
      }),
      _imageManager
          .getImageDataFromFile(curImagePath)
          .then((value) => curImageData = value)
    ]);

    return curImageData != null ? true : false;
  }

  int _getImageFileList(Directory dir) {
    List<FileSystemEntity> files =
        PathUtil.getSpecificFilesFromDirectory(dir, false, (pathname) {
      if (pathname.endsWith(".png") ||
          pathname.endsWith(".jpg") ||
          pathname.endsWith(".jpeg") ||
          pathname.endsWith(".webp")) {
        return true;
      } else {
        return false;
      }
    });

    if (files.isEmpty) return 0;

    imageFileList.clear();
    for (var f in files) {
      imageFileList.add(f.path);
    }

    imageFileList.sort();
    return imageFileList.length;
  }

  bool dragImageForWindows(String targetPath) {
    bool pathIsDir;
    Directory targetDirectory;

    final type = FileSystemEntity.typeSync(targetPath);
    if (type != FileSystemEntityType.directory) {
      File file = File(targetPath);
      if (file.existsSync() == false) return false;
      targetDirectory = Directory(path.dirname(targetPath));
      pathIsDir = false;
    } else {
      targetDirectory = Directory(targetPath);
      pathIsDir = true;
    }

    var fileCount = _getImageFileList(targetDirectory);
    if (fileCount == 0) return false;

    curImageData = null;
    if (pathIsDir) {
      curImageIndex = 0;
      curImagePath = imageFileList[curImageIndex];
    } else {
      var index = imageFileList.indexOf(targetPath);
      if (index == -1) return false;
      curImageIndex = index;
      curImagePath = imageFileList[curImageIndex];
    }

    return true;
  }

  bool dragImage(String targetPath) {
    if (Platform.isWindows) return dragImageForWindows(targetPath);

    final type = FileSystemEntity.typeSync(targetPath);
    if (type != FileSystemEntityType.directory) {
      File file = File(targetPath);
      if (file.existsSync() == false) return false;

      if (!targetPath.endsWith(".png") &&
          !targetPath.endsWith(".jpg") &&
          !targetPath.endsWith(".jpeg") &&
          !targetPath.endsWith(".webp")) {
        return false;
      } else {
        curImageIndex = -1;
        curImageData = null;
        imageFileList.clear();
        curImagePath = targetPath;
      }
      return true;
    } else {
      var fileCount = _getImageFileList(Directory(targetPath));
      if (fileCount == 0) return false;

      curImageIndex = 0;
      curImageData = null;
      curImagePath = imageFileList[curImageIndex];

      return true;
    }
  }
}
