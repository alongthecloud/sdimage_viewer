import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:window_manager/window_manager.dart';
import 'MyHomePage.dart';

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
  bool _handleWindowClosing() {
    var logger = SimpleLogger();
    logger.info('Window closing...');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const titleText = "Image Viewer for SD";

    var logger = SimpleLogger();
    logger.info("run MyApp.build");

    var app = MaterialApp(
        title: titleText,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: titleText));

    return WillPopScope(
        child: app,
        onWillPop: () async {
          return _handleWindowClosing();
        });
  }
}
