import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../ImageAlignment.dart';

class ImageUtil {
  static Offset calcAlignmentOffset(ImageAlignment alignment, Size srcSize,
      Size targetSize, Offset marginPt) {
    int alignX = alignment.value % 10;
    int alignY = alignment.value ~/ 10;

    double offsetX = 0, offsetY = 0;
    switch (alignX) {
      case 0:
        offsetX = (marginPt.dx);
        break;
      case 1:
        offsetX = (targetSize.width - srcSize.width) / 2.0;
        break;
      case 2:
        offsetX = (targetSize.width - srcSize.width) - (marginPt.dx);
        break;
    }

    switch (alignY) {
      case 0:
        offsetY = (marginPt.dy);
        break;
      case 1:
        offsetY = (targetSize.height - srcSize.height) / 2.0;
        break;
      case 2:
        offsetY = (targetSize.height - srcSize.height) - (marginPt.dy);
        break;
    }

    return Offset(offsetX, offsetY);
  }

  static Future<img.Image?> compositeImageWithWaterMark(
    ui.Image? baseImage,
    ui.Image? watermarkImage,
    Offset offset,
  ) async {
    img.Image? imageA = await _convertImage(baseImage);
    if (imageA == null) return null;

    img.Image? imageB = await _convertImage(watermarkImage);
    img.Image finalImage;

    if (imageB == null) {
      finalImage = imageA;
    } else {
      finalImage = await _mergeImage(
          imageA, imageB, offset.dx.toInt(), offset.dy.toInt());
    }
    return finalImage;
  }

  static Future<bool> saveImageWithWatermark(String targetPath,
      ui.Image? baseImage, ui.Image? watermarkImage, Offset offset) async {
    img.Image? finalImage =
        await compositeImageWithWaterMark(baseImage, watermarkImage, offset);
    if (finalImage == null) return false;

    img.encodeJpgFile(targetPath, finalImage, quality: 95);
    return true;
  }

  static String getImageFullPath(
      String outputDir, String baseFullPath, String prefixName) {
    var baseName = p.basenameWithoutExtension(baseFullPath);
    const extension = "jpg";

    String targetDir = outputDir;
    final targetPath = p.join(targetDir, "$prefixName$baseName.$extension");

    return targetPath;
  }

  static Future<img.Image?> _convertImage(ui.Image? uiImage) async {
    if (uiImage == null) return null;

    ByteData? byteData = await uiImage.toByteData();
    if (byteData == null) return null;

    img.Image image = img.Image.fromBytes(
        width: uiImage.width,
        height: uiImage.height,
        bytes: byteData.buffer,
        numChannels: 4);

    return image;
  }

  static Future<img.Image> _mergeImage(
      img.Image imageA, img.Image imageB, int offsetX, int offsetY) async {
    img.Image finalImg = img.compositeImage(
      imageA,
      imageB,
      dstX: offsetX,
      dstY: offsetY,
    );

    return finalImg;
  }
}
