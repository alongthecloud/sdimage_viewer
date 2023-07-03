import 'dart:io';
import 'dart:typed_data';

class ImageManager {
  Future<Uint8List?> getImageDataFromFile(String imagePath) async {
    File file = File(imagePath);
    if (file.existsSync() == false) {
      return null;
    }

    Uint8List u8data = file.readAsBytesSync();
    if (u8data.isEmpty) {
      return null;
    }

    return u8data;
  }
}
