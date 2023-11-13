import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simple_logger/simple_logger.dart';
import '../model/ViewerState.dart';
import '../model/AppConfig.dart';

class ImageView extends StatelessWidget {
  final ViewerState? viewerState;
  final AppConfig? appConfig;

  const ImageView({Key? key, this.viewerState, this.appConfig})
      : super(key: key);

  Widget _getImageWidget(BuildContext context) {
    ui.Image? imageData =
        viewerState != null ? viewerState!.curImageData : null;
    ui.Image? watermarkImageData = appConfig != null
        ? (appConfig!.waterMarkConfig.enable ? appConfig!.waterMarkImage : null)
        : null;
    double watermarkMargin = appConfig != null
        ? appConfig!.waterMarkConfig.marginPx.toDouble()
        : 0.0;

    var watermarkAlignment = appConfig != null
        ? appConfig!.waterMarkConfig.alignment
        : ImageAlignment.topLeft;

    if (imageData == null) {
      return const SizedBox.shrink();
    } else {
      return CustomPaint(
          painter: ImagePainter(
              image: imageData,
              watermarkImage: watermarkImageData,
              watermarkMargin: watermarkMargin,
              watermarkAlignment: watermarkAlignment));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: <Widget>[_getImageWidget(context)]);
  }
}

class ImagePainter extends CustomPainter {
  ui.Image? image;
  ui.Image? watermarkImage;

  double watermarkMargin;
  ImageAlignment watermarkAlignment;

  ImagePainter({
    Listenable? repaint,
    this.image,
    this.watermarkImage,
    this.watermarkMargin = 0.0,
    this.watermarkAlignment = ImageAlignment.topLeft,
  }) : super(repaint: repaint);

  (double, double) _calcScaleFactor(double srcWidth, double srcHeight,
      double targetWidth, double targetHeight) {
    double imageRate = srcWidth / srcHeight;
    double canvasRate = targetWidth / targetHeight;

    double width;
    double height;

    if (imageRate < canvasRate) {
      height = targetHeight;
      width = height * imageRate;
    } else {
      width = targetWidth;
      height = width / imageRate;
    }

    return (width / srcWidth, height / srcHeight);
  }

  (double, double) _calcAlignmentOffset(
      ImageAlignment alignment,
      double srcWidth,
      double srcHeight,
      double canvasWidth,
      double canvasHeight,
      double marginPt,
      (double, double) scaleXY) {
    int alignX = watermarkAlignment.value % 10;
    int alignY = watermarkAlignment.value ~/ 10;

    double offsetX = 0.0;
    double offsetY = 0.0;

    switch (alignX) {
      case 0:
        offsetX = (marginPt * scaleXY.$1);
        break;
      case 1:
        offsetX = (canvasWidth - srcWidth) / 2.0;
        break;
      case 2:
        offsetX = (canvasWidth - srcWidth) - (marginPt * scaleXY.$1);
        break;
    }

    switch (alignY) {
      case 0:
        offsetY = (marginPt * scaleXY.$2);
        break;
      case 1:
        offsetY = (canvasHeight - srcHeight) / 2.0;
        break;
      case 2:
        offsetY = (canvasHeight - srcHeight) - (marginPt * scaleXY.$2);
        break;
    }

    return (offsetX, offsetY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var logger = SimpleLogger();
    // logger.info("ImageView::Paint");

    if (image != null) {
      var imagePaint = Paint()..filterQuality = FilterQuality.high;
      var imgWidth = image!.width.toDouble();
      var imgHeight = image!.height.toDouble();
      var scaleF =
          _calcScaleFactor(imgWidth, imgHeight, size.width, size.height);

      double imgDstWidth = imgWidth * scaleF.$1;
      double imgDstHeight = imgHeight * scaleF.$2;

      double offsetX = (size.width - imgDstWidth) / 2.0;
      double offsetY = (size.height - imgDstHeight) / 2.0;

      canvas.drawImageRect(
          image!,
          Rect.fromLTWH(0, 0, imgWidth, imgHeight),
          Rect.fromLTWH(offsetX, offsetY, imgDstWidth, imgDstHeight),
          imagePaint);

      if (watermarkImage != null) {
        var watermarkPaint = Paint()
          ..filterQuality = FilterQuality.high
          ..blendMode = BlendMode.srcOver;

        var wimgWidth = watermarkImage!.width.toDouble();
        var wimgHeight = watermarkImage!.height.toDouble();
        double wimgDstWidth = wimgWidth * scaleF.$1;
        double wimgDstHeight = wimgHeight * scaleF.$2;

        var offset2 = _calcAlignmentOffset(watermarkAlignment, wimgDstWidth,
            wimgDstHeight, imgDstWidth, imgDstHeight, watermarkMargin, scaleF);

        double wX = offsetX + offset2.$1;
        double wY = offsetY + offset2.$2;

        canvas.drawImageRect(
            watermarkImage!,
            Rect.fromLTWH(0, 0, wimgWidth, wimgHeight),
            Rect.fromLTWH(wX, wY, wimgDstWidth, wimgDstHeight),
            watermarkPaint);

        // logger.info(
        //     "DrawImage $wimgWidth, $wimgHeight - ($wX,$wY - $wimgDstWidth,$wimgDstHeight)");
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
