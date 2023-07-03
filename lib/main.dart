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
  // FFI Initialization.

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    windowManager.getSize().then((size) {
      // WindowEventController.to.updateWindowSize();
    });
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    windowManager.getSize().then((size) {
      // WindowEventController.to.updateWindowSize();
    });
  }

  @override
  void onWindowResize() {
    super.onWindowResize();

    windowManager.getSize().then((size) {
      // WindowEventController.to.updateWindowSize();
    });
  }

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
