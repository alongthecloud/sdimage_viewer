import 'dart:io';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:json_serializer/json_serializer.dart';
import '../ImageAlignment.dart';
import '../ConstValues.dart';
import '../util/PathUtil.dart';

class AppConfig implements Serializable {
  static String appDocumentDirPath = '';

  // json serialization
  String version;
  GeneralConfig? general;
  WaterMarkConfig? watermark;

  // not serialized
  AppUserData appUserData = AppUserData();

  late String appDirPath;
  late String outputDirPath;
  late String appConfigFilePath;

  AppConfig({this.version = "1.0", this.general, this.watermark}) {
    // set up path
    appDirPath = path.join(appDocumentDirPath, ConstValues.AppDirName);
    outputDirPath = path.join(appDirPath, ConstValues.OutputDirName);
    appConfigFilePath = path.join(appDirPath, ConstValues.ConfigFileName);

    _init();
  }

  void _init() async {
    await PathUtil.makeDir(appDirPath);
    await PathUtil.makeDir(outputDirPath);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'version': version, 'general': general, 'watermark': watermark};
  }
}

class GeneralConfig implements Serializable {
  bool savewithmetatext;
  String savefileprefix;

  GeneralConfig({this.savewithmetatext = false, this.savefileprefix = 'sdv_'});

  @override
  Map<String, dynamic> toMap() {
    return {
      'savewithmetatext': savewithmetatext,
      'savefileprefix': savefileprefix
    };
  }
}

class WaterMarkConfig implements Serializable {
  bool enable;
  ImageAlignment alignment;
  int margin;
  String imagePath;

  // default values
  WaterMarkConfig(
      {this.enable = false,
      this.alignment = ImageAlignment.bottomRight,
      this.margin = 2,
      this.imagePath = ''});

  @override
  Map<String, dynamic> toMap() {
    return {
      'enable': enable,
      'alignment': alignment,
      'margin': margin,
      'imagePath': imagePath,
    };
  }
}

class AppUserData {
  ui.Image? waterMarkImage;
}
