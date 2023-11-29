import 'dart:io';
import 'dart:collection';
import 'package:json_serializer/json_serializer.dart';

class DataManager implements Serializable {
  List<String> recentFilePaths = [];

  DataManager(this.recentFilePaths);

  void addRecentFile(File file) {
    if (recentFilePaths.length > 3) {
      recentFilePaths.removeAt(0);
    }

    recentFilePaths.add(file.path);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'recentFiles': recentFilePaths};
  }
}
