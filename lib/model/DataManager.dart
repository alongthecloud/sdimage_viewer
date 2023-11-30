import 'package:json_serializer/json_serializer.dart';

class DataManager implements Serializable {
  final List<String> recentfiles;
  DataManager({required this.recentfiles});

  void addRecentFile(String filePath) {
    if (recentfiles.length >= 3) {
      recentfiles.removeAt(0);
    }

    recentfiles.add(filePath);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'recentfiles': recentfiles};
  }
}
