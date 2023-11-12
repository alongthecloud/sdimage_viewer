import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:oktoast/oktoast.dart';
import './view/MyDropRegion.dart';
import './provider/ViewStateProvider.dart';
import './provider/AppConfigProvider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var logger = SimpleLogger();
    logger.info("run MyHomePage.build");

    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppConfigProvider>(
              create: (context) => AppConfigProvider()),
          ChangeNotifierProvider<ViewStateProvider>(
              create: (context) => ViewStateProvider()),
        ],
        child: Scaffold(
            body: OKToast(
                child: Container(
                    color: Colors.grey, child: const MyDropRegion()))));
  }
}
