import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:oktoast/oktoast.dart';
import 'view/HomeView.dart';
import './provider/ViewStateProvider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  ViewStateProvider? _viewStateProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var logger = SimpleLogger();

    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {});
        logger.info('resumed');
        break;
      case AppLifecycleState.inactive:
        if (_viewStateProvider != null) {
          var viewState = _viewStateProvider!.viewerState;
          logger.info("opened image: ${viewState.curImagePath}");
        }
        logger.info('inactive');
        break;
      case AppLifecycleState.detached:
        logger.info('detached');
        // DO SOMETHING!
        break;
      case AppLifecycleState.paused:
        logger.info('paused');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var logger = SimpleLogger();
    logger.info("run MyHomePage.build");

    return ChangeNotifierProvider(create: (context) {
      _viewStateProvider ??= ViewStateProvider();
      return _viewStateProvider;
    }, builder: (context, child) {
      return Scaffold(
          body: OKToast(
              child: Container(color: Colors.grey, child: const HomeView())));
    });
  }
}
