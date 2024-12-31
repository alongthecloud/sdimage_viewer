import 'package:flutter/widgets.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:json_serializer/json_serializer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/AppConfig.dart';

class AppConfigProvider extends ChangeNotifier {
  late AppConfig appConfig;

  AppConfigProvider() {
    // set up default values
    appConfig = AppConfig(version: "1.0");
  }

  void init() async {
    Future<void> load = this.load();
    load.then((_) {
      save();
      update();
    });
  }

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonText = prefs.getString('appConfig');
    if (jsonText != null) {
      appConfig = deserialize<AppConfig>(jsonText!);
    }
  }

  Future<void> save() async {
    var logger = SimpleLogger();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var jsonText = serialize(appConfig);
    await prefs.setString('appConfig', jsonText);

    logger.info("AppConfig saved.");
  }

  void update() async {
    notifyListeners();
  }
}
