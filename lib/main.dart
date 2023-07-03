import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sdimage_viewer/Controller/ViewerStateController.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import 'MyHomePage.dart';
import './controller/WindowEventController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  final logger = SimpleLogger();
  if (kReleaseMode) {
    logger.setLevel(Level.WARNING);
  }

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
    Get.put(WindowEventController());
    Get.put(ViewerStateController());

    const titleText = "Image Viewer for SD";
    var myHomePage = const MyHomePage(title: titleText);

    var logger = SimpleLogger();
    logger.info("run MyApp.build");

    return GetMaterialApp(
      title: titleText,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: myHomePage,
    );
  }
}
