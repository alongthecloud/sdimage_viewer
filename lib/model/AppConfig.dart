import 'dart:ui' as ui;
import '../util/ImageUtil.dart';

class AppConfig {
  WaterMarkConfig waterMarkConfig = WaterMarkConfig();

  ui.Image? waterMarkImage;
}

class WaterMarkConfig {
  bool enable = false;
  ImageAlignment alignment = ImageAlignment.bottomRight;
  int marginPx = 0;
  String? fullPath;
}
