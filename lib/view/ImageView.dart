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
      return CustomPaint(painter: ImagePainter(image: image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: <Widget>[_getImageWidget(context, viewerState.curImageData)]);
  }
}

class ImagePainter extends CustomPainter {
  ui.Image? image;
  ui.Image? waterMark;

  Offset waterMarkOffset;
  Alignment waterMarkAlignment;

  ImagePainter({
    Listenable? repaint,
    this.image,
    this.waterMark,
    this.waterMarkOffset = Offset.zero,
    this.waterMarkAlignment = Alignment.bottomRight,
  }) : super(repaint: repaint);

  (double, double) _scaleToFitCanvas(
      double w1, double h1, double w2, double h2) {
    double imageRate = w1 / h1;
    double canvasRate = w2 / h2;

    double width, height;

    if (imageRate > canvasRate) {
      height = w2 / imageRate;
      width = w2;
    } else {
      width = h2 * imageRate;
      height = h2;
    }

    return (width, height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      var imagePaint = Paint()..filterQuality = FilterQuality.high;

      var imageRect = Rect.fromLTWH(
          0, 0, image!.width.toDouble(), image!.height.toDouble());

      var rescaleSize = _scaleToFitCanvas(
          imageRect.width, imageRect.height, size.width, size.height);

      var offsetX = (size.width - rescaleSize.$1) / 2;
      var offsetY = (size.height - rescaleSize.$2) / 2;

      var targetRect =
          Rect.fromLTWH(offsetX, offsetY, rescaleSize.$1, rescaleSize.$2);

      canvas.drawImageRect(image!, imageRect, targetRect, imagePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
