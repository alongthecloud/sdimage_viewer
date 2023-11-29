import 'dart:io';
import 'dart:ui' as ui;
import 'package:json_serializer/json_serializer.dart';
import '../ImageAlignment.dart';
import '../util/PathUtil.dart';
import './AppPath.dart';

class AppConfig implements Serializable {
  // json serialization
  String version;
  GeneralConfig? general;
  WaterMarkConfig? watermark;

  // not serialized
  AppUserData appUserData = AppUserData();

  AppConfig({this.version = "1.0", this.general, this.watermark}) {
    _init();
  }

  void _init() async {
    var appPath = AppPath();

    await PathUtil.makeDir(appPath.appDirPath);
    await PathUtil.makeDir(appPath.outputDirPath);
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
