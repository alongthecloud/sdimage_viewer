import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:sdimage_viewer/ExifToolExec.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:json_serializer/json_serializer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DataManager.dart';
import 'ImageManager.dart';
import '../util/PathUtil.dart';
import '../util/Metadata.dart';
import '../provider/ViewerStateProvider.dart';

class FileInfo {
  String path = "";
  int size = 0;
  DateTime modifiedDate = DateTime(0);

  @override
  String toString() {
    return 'FileInfo{path: $path, size: $size, modifiedDate: $modifiedDate}';
  }
}

class ViewerState {
  final ImageManager _imageManager = ImageManager();
  DataManager dataManager =
      DataManager(recentfiles: <String>[], sortType: 0, sortDescending: false);

  List<FileInfo> imageFileList = [];
  String curImagePath = "";

  int curImageIndex = -1;
  ui.Image? curImageData;
  MetaData curImageMetaData = MetaData();

  StreamSubscription<FileSystemEvent>? eventSub;

  String? getRecentFilePath() {
    int lastIndex = dataManager.recentfiles.length - 1;
    if (lastIndex < 0) {
      return null;
    }
    String filePath = dataManager.recentfiles[lastIndex];
    if (filePath.isEmpty) {
      return null;
    }

    return filePath;
  }

  void addRecentFile(String filePath) {
    if (dataManager.recentfiles.length >= 3) {
      dataManager.recentfiles.removeAt(0);
    }

    dataManager.recentfiles.add(filePath);
  }

  void changeSortType(int sortType, bool sortDescending) {
    bool isChanged = (dataManager.sortType != sortType ||
        dataManager.sortDescending != sortDescending);
    if (!isChanged) return;

    dataManager.sortType = sortType;
    dataManager.sortDescending = sortDescending;

    dragImage(curImagePath);
  }

  void save() async {
    // save data (DataManager)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonText = serialize(dataManager);
    await prefs.setString('dataManager', jsonText);
  }

  String getCurrentPositionText() {
    return "${curImageIndex + 1} / ${imageFileList.length}";
  }

  Future<bool> moveToRelativeStep(int step) async {
    int nextIndex = (curImageIndex + step);
    if (imageFileList.isEmpty) return false;
    if (nextIndex >= imageFileList.length) nextIndex = imageFileList.length - 1;
    if (nextIndex < 0) nextIndex = 0;

    curImageIndex = nextIndex;
    return await updateImage();
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
      curImagePath = imageFileList[curImageIndex].path;
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
      _imageManager.getImageDataFromFile(curImagePath).then((value) {
        addRecentFile(curImagePath);
        return curImageData = value;
      })
    ]);

    return curImageData != null ? true : false;
  }

  void _sortImageFiles() {
    var logger = SimpleLogger();
    logger.info("sortImageFiles");

    switch (dataManager.sortType) {
      case 0: // filename
        if (dataManager.sortDescending) {
          imageFileList.sort((a, b) => b.path.compareTo(a.path));
        } else {
          imageFileList.sort((a, b) => a.path.compareTo(b.path));
        }
        break;
      case 1: // date
        if (dataManager.sortDescending) {
          imageFileList
              .sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
        } else {
          imageFileList
              .sort((a, b) => a.modifiedDate.compareTo(b.modifiedDate));
        }
        break;
      case 2: // size
        if (dataManager.sortDescending) {
          imageFileList.sort((a, b) => b.size.compareTo(a.size));
        } else {
          imageFileList.sort((a, b) => a.size.compareTo(b.size));
        }
        break;
      default:
        return;
    }

    logger.info("${imageFileList.toString()}, ${dataManager.sortDescending}");
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

    for (var file in files) {
      FileInfo fileInfo = FileInfo();
      fileInfo.path = file.path;
      FileStat fileStat = file.statSync();
      fileInfo.size = fileStat.size;
      fileInfo.modifiedDate = fileStat.modified;

      imageFileList.add(fileInfo);
    }

    _sortImageFiles();
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
        var index =
            imageFileList.indexWhere((element) => element.path == targetPath);
        if (index == -1) return false;
        curImageIndex = index;
      }

      curImagePath = imageFileList[curImageIndex].path;
    }

    if (eventSub != null) {
      eventSub!.cancel();
      eventSub = null;
    }

    var stream = targetDirectory.watch();
    eventSub = stream.listen((event) {
      var viewStateProvider = ViewerStateProvider();
      var curImageFile = File(curImagePath);
      String aPath =
          curImageFile.existsSync() ? curImagePath : targetDirectory!.path;

      viewStateProvider.dragImagePath(aPath);
    });

    return true;
  }
}
