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

  void getNextImage() async {
    bool result = await viewerState.getNextImage();
    if (result) {
      update();
    }
  }

  void getPreviousImage() async {
    bool result = await viewerState.getPreviousImage();
    if (result) {
      update();
    }
  }

  void update() {
    notifyListeners();
  }
}
