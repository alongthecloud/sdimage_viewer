import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:sdimage_viewer/ExifToolExec.dart';
import 'package:simple_logger/simple_logger.dart';
import 'ImageManager.dart';
import '../util/PathUtil.dart';
import '../util/Metadata.dart';
import '../provider/ViewStateProvider.dart';

class ViewerState {
  final ImageManager _imageManager = ImageManager();

  List<String> imageFileList = [];
  String curImagePath = "";

  int curImageIndex = -1;
  ui.Image? curImageData;
  MetaData curImageMetaData = MetaData();

  StreamSubscription<FileSystemEvent>? eventSub;

  String getCurrentPositionText() {
    return "${curImageIndex + 1} / ${imageFileList.length}";
  }

  Future<bool> _moveToRelativeStep(int step) async {
    int nextIndex = (curImageIndex + step);
    if (imageFileList.isEmpty) return false;
    if (nextIndex >= imageFileList.length) nextIndex = imageFileList.length - 1;
    if (nextIndex < 0) nextIndex = 0;

    curImageIndex = nextIndex;
    return await updateImage();
  }

  Future<bool> moveToNext() async {
    return await _moveToRelativeStep(1);
  }

  Future<bool> moveToPrev() async {
    return await _moveToRelativeStep(-1);
  }

  Future<bool> moveToFirst() async {
    curImageIndex = 0;
    return await updateImage();
  }

  Future<bool> moveToLast() async {
    curImageIndex = imageFileList.length - 1;
    return await updateImage();
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

  bool dragImage(String targetPath) {
    var logger = SimpleLogger();
    logger.info("dragImage: $targetPath");

    bool pathIsDir = false;
    Directory? targetDirectory;

    final type = FileSystemEntity.typeSync(targetPath);
    if (type == FileSystemEntityType.directory) {
      pathIsDir = true;
      targetDirectory = Directory(targetPath);
    } else if (type == FileSystemEntityType.file) {
      pathIsDir = false;
    } else {
      return false;
    }

    if (pathIsDir == false) {
      if (!targetPath.endsWith(".png") &&
          !targetPath.endsWith(".jpg") &&
          !targetPath.endsWith(".jpeg") &&
          !targetPath.endsWith(".webp")) {
        return false;
      }

      curImagePath = targetPath;
      curImageIndex = -1;
      curImageData = null;
      imageFileList.clear();
      if (Platform.isWindows) {
        targetDirectory = Directory(path.dirname(targetPath));
      } else {
        return true;
      }
    }

    if (targetDirectory == null) return false;
    if (targetDirectory.existsSync() == false) return false;

    var fileCount = _getImageFileList(targetDirectory);
    if (fileCount > 0) {
      if (pathIsDir) {
        curImageIndex = 0;
      } else {
        var index = imageFileList.indexOf(targetPath);
        if (index == -1) return false;
        curImageIndex = index;
      }

      curImagePath = imageFileList[curImageIndex];
    }

    if (eventSub != null) {
      eventSub!.cancel();
      eventSub = null;
    }

    var stream = targetDirectory.watch();
    eventSub = stream.listen((event) {
      var viewStateProvider = ViewStateProvider();
      var curImageFile = File(curImagePath);
      String aPath =
          curImageFile.existsSync() ? curImagePath : targetDirectory!.path;

      viewStateProvider.dragImagePath(aPath);
    });

    return true;
  }
}
