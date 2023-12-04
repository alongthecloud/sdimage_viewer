import 'dart:io';

import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sdimage_viewer/view/ButtonBarView.dart';
import 'package:window_manager/window_manager.dart';
import '../provider/ViewerStateProvider.dart';
import '../provider/AppConfigProvider.dart';
import '../model/ViewerState.dart';
import '../model/AppConfig.dart';
import './ImagePropertyView.dart';
import './ImageView.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  void _onKeyEvent(RawKeyEvent event, ViewerStateProvider viewerStateProvider) {
    if (event.runtimeType == RawKeyDownEvent) {
      switch (event.physicalKey) {
        case PhysicalKeyboardKey.arrowLeft:
          viewerStateProvider.moveToRelativeStep(-1);
          break;
        case PhysicalKeyboardKey.arrowRight:
          viewerStateProvider.moveToRelativeStep(1);
          break;
        case PhysicalKeyboardKey.arrowDown:
          viewerStateProvider.moveToRelativeStep(-10);
          break;
        case PhysicalKeyboardKey.arrowUp:
          viewerStateProvider.moveToRelativeStep(10);
          break;
        case PhysicalKeyboardKey.home:
          viewerStateProvider.moveToFirstImage();
          break;
        case PhysicalKeyboardKey.end:
          viewerStateProvider.moveToLastImage();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewerStateProvider>(
        builder: (context, viewStateProvider, child) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        var imageFilename =
            Path.basename(viewStateProvider.viewerState.curImagePath);
        windowManager.setTitle(imageFilename);
      }

      var appConfigProvider =
          Provider.of<AppConfigProvider>(context, listen: false);

      return RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) => _onKeyEvent(event, viewStateProvider),
          child: SizedBox(
              child: DropTarget(child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final ratio = width / height;
              if (width < 720 || ratio < 0.8) {
                return _mobileBody(
                    context, viewStateProvider, appConfigProvider);
              } else {
                return _desktopBody(
                    context, viewStateProvider, appConfigProvider);
              }
            },
          ), onDragDone: (details) {
            var files = details.files;
            if (files.isNotEmpty) {
              var path = files[0].path;
              viewStateProvider.dragImagePath(path);
            }
          })));
    });
  }

  Widget _bottomBarWidget(
      BuildContext context, ViewerStateProvider viewStateProvider) {
    ViewerState viewerState = viewStateProvider.viewerState;

    var bottomBarItems = <Widget>[
      IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_left),
          onPressed: () {
            viewStateProvider.moveToFirstImage();
          }),
      IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            viewStateProvider.moveToRelativeStep(-1);
          }),
      Text(viewStateProvider.getCurrentPositionText()),
      IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            viewStateProvider.moveToRelativeStep(1);
          }),
      IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_right),
          onPressed: () {
            viewStateProvider.moveToLastImage();
          }),
    ];

    var bottomBar = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: viewerState.curImageIndex != -1
            ? bottomBarItems
            : const <Widget>[]);
    return bottomBar;
  }

  Widget _mainViewWidget(
      BuildContext context, ViewerState viewerState, AppConfig appConfig) {
    return Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 0, 1),
        child: ImageView(viewerState: viewerState, appConfig: appConfig));
  }

  Widget _desktopBody(
      BuildContext context,
      ViewerStateProvider viewStateProvider,
      AppConfigProvider appConfigProvider) {
    // left to right
    var childWidgets = [
      Expanded(
          child: _mainViewWidget(context, viewStateProvider.viewerState,
              appConfigProvider.appConfig)),
      const VerticalDivider(thickness: 1, width: 5),
      SizedBox(
          width: 380,
          child: Column(children: [
            ButtonBarView(viewerState: viewStateProvider.viewerState),
            const SizedBox(height: 2),
            ImagePropertyView(viewerState: viewStateProvider.viewerState)
          ]))
    ]; // return Container(color: Colors.grey, child: childWidget);

    return Column(children: [
      Expanded(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: childWidgets)),
      Container(
          color: Colors.white,
          height: 42,
          child: _bottomBarWidget(context, viewStateProvider))
    ]);
  }

  Widget _mobileBody(
      BuildContext context,
      ViewerStateProvider viewStateProvider,
      AppConfigProvider appConfigProvider) {
    return Column(children: [
      Flexible(
          fit: FlexFit.tight,
          child: Stack(children: [
            _mainViewWidget(context, viewStateProvider.viewerState,
                appConfigProvider.appConfig),
            ButtonBarView(viewerState: viewStateProvider.viewerState),
          ])),
      const Divider(height: 3, thickness: 1),
      Expanded(
          child: ImagePropertyView(viewerState: viewStateProvider.viewerState)),
      Container(
          height: 36,
          color: Colors.white,
          child: _bottomBarWidget(context, viewStateProvider))
    ]);
  }
}
