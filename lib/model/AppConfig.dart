import 'package:json_serializer/json_serializer.dart';

class AppConfig implements Serializable {
  // json serialization
  String version;
  Map<String, dynamic> general = {};

  AppConfig({this.version = "1.0"});

  @override
  Map<String, dynamic> toMap() {
    return {'version': version, 'general': general};
  }
}
