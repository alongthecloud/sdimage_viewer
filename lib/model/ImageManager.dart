import 'dart:io';
import 'dart:ui' as ui;

class ImageManager {
  Future<ui.Image?> getImageDataFromFile(String imagePath) async {
    File file = File(imagePath);
    if (file.existsSync() == false) {
      return null;
    }

    ui.Image? image;

    try {
      var byteData = await file.readAsBytes();
      ui.Codec result = await ui.instantiateImageCodec(byteData);
      ui.FrameInfo frame = await result.getNextFrame();
      image = frame.image;
    } catch (e) {
      return null;
    }

    return image;
  }
}
