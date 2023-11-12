import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import '../model/AppConfig.dart';
import '../model/ImageManager.dart';

class AppConfigProvider extends ChangeNotifier {
  final AppConfig appConfig = AppConfig();

  ImageManager _imageManager = ImageManager();
  ui.Image? _waterMarkImage;

  AppConfigProvider() {
    init();
  }

  void init() {
    var waterMarkConfig = appConfig.waterMarkConfig;
    if (waterMarkConfig.enable) {
      if (waterMarkConfig.fullPath != null) {
        _imageManager
            .getImageDataFromFile(appConfig.waterMarkConfig.fullPath!)
            .then((value) {
          _waterMarkImage = value;
          update();
        });
      }
    }
  }

  void update() {
    notifyListeners();
  }
}
