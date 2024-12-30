import 'package:flutter/widgets.dart';
import '../model/AppConfig.dart';
import '../model/ImageManager.dart';

class AppConfigProvider extends ChangeNotifier {
  final ImageManager _imageManager = ImageManager();
  late AppConfig appConfig;

  AppConfigProvider() {
    // set up default values
    appConfig = AppConfig(version: "1.0");
  }

  void init() async {
    appConfig.watermark ??= WaterMarkConfig();
    appConfig.general ??= GeneralConfig();

    save();
    update();
  }

  Future<void> save() async {}

  Future<void> _updateWatermarkImage() async {
    var waterMarkConfig = appConfig.watermark;
    if (waterMarkConfig != null && waterMarkConfig.enable) {
      if (waterMarkConfig.imagePath.isNotEmpty) {
        var image =
            await _imageManager.getImageDataFromFile(waterMarkConfig.imagePath);

        appConfig.appUserData.waterMarkImage = image;
        return;
      }
    }
  }

  void update() async {
    await _updateWatermarkImage();
    notifyListeners();
  }
}
