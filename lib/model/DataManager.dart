import 'package:json_serializer/json_serializer.dart';

class SortType {
  static const int filename = 0;
  static const int date = 1;
  static const int size = 2;

  static const List<String> names = ['Filename', 'Date', 'Size'];
}

class DataManager implements Serializable {
  final List<String> recentfiles;
  int sortType;
  bool sortDescending = true;

  DataManager(
      {required this.recentfiles,
      this.sortType = 0,
      this.sortDescending = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      'recentfiles': recentfiles,
      'sortType': sortType,
      'sortDescending': sortDescending
    };
  }
}
