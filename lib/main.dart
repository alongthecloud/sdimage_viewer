import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:json_serializer/json_serializer.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:window_manager/window_manager.dart';
import './provider/AppConfigProvider.dart';
import './model/AppPath.dart';
import './model/AppConfig.dart';
import './model/DataManager.dart';
import 'ImageAlignment.dart';
import 'MyHomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  final logger = SimpleLogger();
  if (kReleaseMode) {
    logger.setLevel(Level.WARNING);
  }

  JsonSerializer.options = JsonSerializerOptions(types: [
    UserType<AppConfig>(AppConfig.new),
    UserType<WaterMarkConfig>(WaterMarkConfig.new),
    UserType<GeneralConfig>(GeneralConfig.new),
    UserType<DataManager>(DataManager.new),
    EnumType<ImageAlignment>(ImageAlignment.values),
  ]);

  var appPath = AppPath();
  await appPath.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    const titleText = "Image Viewer for SD";

    var logger = SimpleLogger();
    logger.info("run MyApp.build");

    return ChangeNotifierProvider(create: (context) {
      var appConfigProvider = AppConfigProvider();
      appConfigProvider.init();
      return appConfigProvider;
    }, builder: (context, child) {
      var app = MaterialApp(
          title: titleText,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: titleText));

      // return app;
      return app;
    });
  }
}
