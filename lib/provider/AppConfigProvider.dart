import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:json_serializer/json_serializer.dart';
import '../model/AppConfig.dart';
import '../model/ImageManager.dart';
import '../util/PathUtil.dart';
import '../util/Util.dart';
import '../ConstValues.dart';
import '../ImageAlignment.dart';

class AppConfigProvider extends ChangeNotifier {
  final ImageManager _imageManager = ImageManager();
  late AppConfig appConfig;

  late String appDirPath;
  late String outputDirPath;
  late String appConfigFilePath;

  AppConfigProvider() {
    // set up default values
    appConfig = AppConfig(version: "1.0", watermark: WaterMarkConfig());
  }

  void init() async {
    JsonSerializer.options = JsonSerializerOptions(types: [
      UserType<AppConfig>(AppConfig.new),
      UserType<WaterMarkConfig>(WaterMarkConfig.new),
      EnumType<ImageAlignment>(ImageAlignment.values),
    ]);

    var logger = SimpleLogger();

    // set up path
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    appDirPath = path.join(appDocumentsDir.path, ConstValues.AppDirName);
    outputDirPath = path.join(appDirPath, ConstValues.OutputDirName);

    await PathUtil.makeDir(appDirPath);
    await PathUtil.makeDir(outputDirPath);
    appConfigFilePath = path.join(appDirPath, ConstValues.ConfigFileName);

    try {
      var jsonLoadedText = Util.loadTextFile(appConfigFilePath);
      appConfig = deserialize<AppConfig>(jsonLoadedText!);
    } catch (e) {
      logger.warning(e.toString());
    }

    update();
  }

  Future<void> save() async {
    if (appConfigFilePath.isNotEmpty) {
      var jsonText = serialize(appConfig);
      await Util.saveTextFile(jsonText, appConfigFilePath);
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
