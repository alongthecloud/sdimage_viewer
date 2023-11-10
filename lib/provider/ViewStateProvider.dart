import 'package:flutter/widgets.dart';
import '../model/ViewerState.dart';

class ViewStateProvider extends ChangeNotifier {
  ViewStateProvider._privateConstructor();
  static final ViewStateProvider _instance =
      ViewStateProvider._privateConstructor();
  factory ViewStateProvider() {
    return _instance;
  }

  ViewerState viewerState = ViewerState();

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
