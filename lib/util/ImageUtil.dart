import 'dart:io';
import 'package:flutter/material.dart';

class ImageUtil {
  static Widget roundWidget(Widget widget, double radius) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius), child: widget);
  }
}
