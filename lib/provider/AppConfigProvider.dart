import 'package:flutter/widgets.dart';
import '../model/AppConfig.dart';
import '../model/ImageManager.dart';

class AppConfigProvider extends ChangeNotifier {
  final ImageManager _imageManager = ImageManager();
  final AppConfig appConfig = AppConfig();

  AppConfigProvider() {
    init();
  }

  void init() {
    update();
  }

  Future<void> _updateImage() async {
    var waterMarkConfig = appConfig.waterMarkConfig;
    if (waterMarkConfig.enable) {
      if (waterMarkConfig.fullPath != null) {
        var image = await _imageManager
            .getImageDataFromFile(appConfig.waterMarkConfig.fullPath!);

        appConfig.waterMarkImage = image;
        return;
      }
    }
  }

  void update() async {
    await _updateImage();
    notifyListeners();
  }
}
