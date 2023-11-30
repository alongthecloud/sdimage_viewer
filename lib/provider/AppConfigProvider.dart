import 'package:flutter/widgets.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:json_serializer/json_serializer.dart';
import '../model/AppConfig.dart';
import '../model/ImageManager.dart';
import '../model/AppPath.dart';
import '../util/Util.dart';

class AppConfigProvider extends ChangeNotifier {
  final ImageManager _imageManager = ImageManager();
  late AppConfig appConfig;

  AppConfigProvider() {
    // set up default values
    appConfig = AppConfig(version: "1.0");
  }

  void init() async {
    var appPath = AppPath();
    var logger = SimpleLogger();

    try {
      var jsonLoadedText = Util.loadTextFile(appPath.appConfigFilePath);
      appConfig = deserialize<AppConfig>(jsonLoadedText!);
    } catch (e) {
      logger.warning(e.toString());
    }

    appConfig.watermark ??= WaterMarkConfig();
    appConfig.general ??= GeneralConfig();

    save();
    update();
  }

  Future<void> save() async {
    var appPath = AppPath();
    if (appPath.appConfigFilePath.isNotEmpty) {
      var jsonText = serialize(appConfig);
      await Util.saveTextFile(jsonText, appPath.appConfigFilePath);
    }
  }

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
