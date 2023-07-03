import 'dart:io';
import 'package:flutter/material.dart';

class ImageUtil {
  // no use
  // static bool _isInited = false;
  // static Image? defaultPersonIcon = null;
  // static Image? defaultIcon = null;

  // static void initialize() {
  //   if (_isInited) return;
  //   _isInited = true;

  //   defaultPersonIcon = Image.asset("assets/people.png");
  //   defaultIcon = Image.asset("assets/default.png");
  // }

  static Image? loadFromPath(String path, double width, double height,
      {BoxFit fit = BoxFit.cover,
      FilterQuality filterQuality = FilterQuality.low}) {
    // String ext = Path.extension(path);

    File imageFile = File(path);
    if (imageFile.existsSync()) {
      var imageWidget = Image.file(imageFile,
          width: width == 0.0 ? null : width,
          height: height == 0.0 ? null : height,
          fit: fit,
          isAntiAlias: true,
          filterQuality: filterQuality);

      return imageWidget;
    } else {
      return null;
    }
  }

  static Widget roundWidget(Widget widget, double radius) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius), child: widget);
  }
}
