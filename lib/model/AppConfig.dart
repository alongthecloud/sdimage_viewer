import 'dart:ui' as ui;

enum ImageAlignment {
  topLeft(00),
  topCenter(01),
  topRight(02),
  centerLeft(10),
  center(11),
  centerRight(12),
  bottomLeft(20),
  bottomCenter(21),
  bottomRight(22);

  // can add more properties or getters/methods if needed
  final int value;
  // can use named parameters if you want
  const ImageAlignment(this.value);
}

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
