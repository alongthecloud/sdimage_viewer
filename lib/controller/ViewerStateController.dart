import 'package:get/get.dart';
import '../model/ViewerState.dart';

class ViewerStateController extends GetxController {
  static ViewerStateController get to => Get.find();

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
}
