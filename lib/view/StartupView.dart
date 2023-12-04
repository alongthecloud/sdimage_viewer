import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../model/AppPath.dart';
import '../provider/AppConfigProvider.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  Widget _getTextWidget(AppPath appPath) {
    return Column(
      children: [
        const Text(
            'The program creates the following directories for setup and storage'),
        const SizedBox(height: 8),
        Text('* Application directory   : ${appPath.appDirPath}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var appConfigProvider =
        Provider.of<AppConfigProvider>(context, listen: false);

    var appPath = AppPath();
    var app = Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _getTextWidget(appPath),
          const SizedBox(height: 20),
          OutlinedButton(
            child: const Text('Start'),
            onPressed: () {
              appPath.makeDir().then((_) {
                appConfigProvider.init();
              });
            },
          )
        ],
      )),
    );

    // return app;
    return app;
  }
}
