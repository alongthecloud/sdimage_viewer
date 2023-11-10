import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/ViewerState.dart';

class ImageView extends StatelessWidget {
  final ViewerState viewerState;

  const ImageView({Key? key, required this.viewerState}) : super(key: key);

  Widget _getImageWidget(BuildContext context, ui.Image? image) {
    if (image == null) {
      return const SizedBox.shrink();
    } else {
      return RawImage(
          image: image, fit: BoxFit.contain, filterQuality: FilterQuality.high);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _getImageWidget(context, viewerState.curImageData);
  }
}
