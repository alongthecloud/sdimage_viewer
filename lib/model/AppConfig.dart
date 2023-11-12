class AppConfig {
  WaterMarkConfig waterMarkConfig = WaterMarkConfig();
}

class WaterMarkConfig {
  bool enable = false;
  int positionIndex = 0;
  int marginPx = 0;
  String? fullPath;
}
