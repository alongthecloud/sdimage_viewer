import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:oktoast/oktoast.dart';
import './view/MyDropRegion.dart';
import './controller/WindowEventController.dart';

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

    return GetBuilder<WindowEventController>(builder: (controller) {
      logger.info("MyHomepage.build");

      Widget body = Container(
        color: Colors.grey,
        child: const MyDropRegion(),
      );

      return Scaffold(body: OKToast(child: body));
    });
  }
}
