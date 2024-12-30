import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simple_logger/simple_logger.dart';
import '../model/ViewerState.dart';
import '../model/AppConfig.dart';
import '../util/ImageUtil.dart';
import '../ImageAlignment.dart';

class ImageView extends StatelessWidget {
  final ViewerState? viewerState;
  final AppConfig? appConfig;

  const ImageView({super.key, this.viewerState, this.appConfig});

  Widget _getImageWidget(BuildContext context) {
    ui.Image? imageData = viewerState?.curImageData;

    if (imageData == null) {
      return const SizedBox.shrink();
    } else {
      return CustomPaint(
          painter: ImagePainter(
              image: imageData,
              watermarkImage: null,
              watermarkMargin: 0.0,
              watermarkAlignment: ImageAlignment.bottomRight));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: <Widget>[_getImageWidget(context)]);

    // return _getImageWidget(context);
  }
}

class ImagePainter extends CustomPainter {
  ui.Image? image;
  ui.Image? watermarkImage;

  double watermarkMargin;
  ImageAlignment watermarkAlignment;

  ImagePainter({
    super.repaint,
    this.image,
    this.watermarkImage,
    this.watermarkMargin = 0.0,
    this.watermarkAlignment = ImageAlignment.topLeft,
  });

  Offset _calcScaleFactor(double srcWidth, double srcHeight, double targetWidth,
      double targetHeight) {
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

    return Offset(width / srcWidth, height / srcHeight);
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

      double imgDstWidth = imgWidth * scaleF.dx;
      double imgDstHeight = imgHeight * scaleF.dy;

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

        Size wImgSize = Size(watermarkImage!.width.toDouble(),
            watermarkImage!.height.toDouble());
        Size wScaledSize =
            Size(wImgSize.width * scaleF.dx, wImgSize.height * scaleF.dy);

        Offset scaledMargin =
            Offset(watermarkMargin * scaleF.dx, watermarkMargin * scaleF.dy);

        var offset2 = ImageUtil.calcAlignmentOffset(watermarkAlignment,
            wScaledSize, Size(imgDstWidth, imgDstHeight), scaledMargin);

        double wX = offsetX + offset2.dx;
        double wY = offsetY + offset2.dy;

        canvas.drawImageRect(
            watermarkImage!,
            Rect.fromLTWH(0, 0, wImgSize.width, wImgSize.height),
            Rect.fromLTWH(wX, wY, wScaledSize.width, wScaledSize.height),
            watermarkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    return false;
  }
}
