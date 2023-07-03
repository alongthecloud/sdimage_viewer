import 'package:get/get.dart';

class WindowEventController extends GetxController {
  static WindowEventController get to => Get.find();

  void updateWindowSize() {
    update();
  }
}
