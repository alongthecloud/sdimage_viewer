import 'dart:ui' as ui;
import 'package:json_serializer/json_serializer.dart';
import '../ImageAlignment.dart';

class AppConfig implements Serializable {
  AppUserData appUserData = AppUserData();

  String version;
  WaterMarkConfig? watermark;

  AppConfig({this.version = "1.0", this.watermark});

  @override
  Map<String, dynamic> toMap() {
    return {'version': version, 'watermark': watermark};
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
