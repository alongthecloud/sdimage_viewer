import 'package:flutter/widgets.dart';
import 'package:json_serializer/json_serializer.dart';
import 'package:simple_logger/simple_logger.dart';
import '../model/AppPath.dart';
import '../model/DataManager.dart';
import '../model/ViewerState.dart';
import '../util/Util.dart';

class ViewerStateProvider extends ChangeNotifier {
  ViewerStateProvider._privateConstructor();
  static final ViewerStateProvider _instance =
      ViewerStateProvider._privateConstructor();
  factory ViewerStateProvider() {
    return _instance;
  }

  ViewerState viewerState = ViewerState();

  void init() {
    var logger = SimpleLogger();

    try {
      var appPath = AppPath();
      var jsonLoadedText = Util.loadTextFile(appPath.appDataFilePath);
      var dataManager = deserialize<DataManager>(jsonLoadedText!);
      viewerState.dataManager = dataManager;

      String? filePath = viewerState.getRecentFilePath();
      if (filePath != null) {
        dragImagePath(filePath);
      }
    } catch (e) {
      logger.warning(e.toString());
    }
  }

  void dragImagePath(String imagePath) async {
    if (viewerState.dragImage(imagePath)) {
      if (await viewerState.updateImage()) {
        update();
      }
    }
  }

  String getCurrentPositionText() {
    return viewerState.getCurrentPositionText();
  }

  void moveToRelativeStep(int step) async {
    updateWhenTrue(viewerState.moveToRelativeStep(step));
  }

  void moveToFirstImage() async {
    updateWhenTrue(viewerState.moveToFirst());
  }

  void moveToLastImage() async {
    updateWhenTrue(viewerState.moveToLast());
  }

  void updateWhenTrue(Future<bool> func) async {
    bool result = await func;
    if (result) {
      update();
    }
  }

  void update() {
    notifyListeners();
  }
}
