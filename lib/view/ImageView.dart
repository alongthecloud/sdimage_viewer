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

  const ImageView({Key? key, this.viewerState, this.appConfig})
      : super(key: key);

  Widget _getImageWidget(BuildContext context) {
    var appUserData = appConfig!.appUserData;
    var watermarkconfig = appConfig!.watermark;

    ui.Image? imageData =
        viewerState != null ? viewerState!.curImageData : null;

    ui.Image? watermarkImageData;
    double watermarkMargin = 2.0;
    var watermarkAlignment = ImageAlignment.bottomRight;
    if (appConfig != null &&
        watermarkconfig != null &&
        watermarkconfig.enable) {
      watermarkImageData = appUserData.waterMarkImage;
      watermarkMargin = watermarkconfig.margin.toDouble();
      watermarkAlignment = watermarkconfig.alignment;
    }

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

    // return _getImageWidget(context);
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
