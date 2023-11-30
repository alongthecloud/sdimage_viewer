import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
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

  Widget _mainWidgets(
      BuildContext context, ViewerState viewerState, AppConfig appConfig) {
    // left to right
    var childWidgets = [
      Expanded(
          child: Container(
              margin: const EdgeInsets.fromLTRB(1, 1, 0, 1),
              child:
                  ImageView(viewerState: viewerState, appConfig: appConfig))),
      const VerticalDivider(thickness: 1, width: 5),
      ImagePropertyView(viewerState: viewerState)
    ]; // return Container(color: Colors.grey, child: childWidget);
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: childWidgets);
  }

  Widget _bodyWidget(
      BuildContext context,
      ViewerStateProvider viewStateProvider,
      AppConfigProvider appConfigProvider) {
    ViewerState viewerState = viewStateProvider.viewerState;

    var imageFilename = Path.basename(viewerState.curImagePath);
    windowManager.setTitle(imageFilename);

    return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.runtimeType == RawKeyDownEvent) {
            switch (event.physicalKey) {
              case PhysicalKeyboardKey.arrowLeft:
                viewStateProvider.moveToRelativeStep(-1);
                break;
              case PhysicalKeyboardKey.arrowRight:
                viewStateProvider.moveToRelativeStep(1);
                break;
              case PhysicalKeyboardKey.arrowDown:
                viewStateProvider.moveToRelativeStep(-10);
                break;
              case PhysicalKeyboardKey.arrowUp:
                viewStateProvider.moveToRelativeStep(10);
                break;
              case PhysicalKeyboardKey.home:
                viewStateProvider.moveToFirstImage();
                break;
              case PhysicalKeyboardKey.end:
                viewStateProvider.moveToLastImage();
                break;
            }
          }
        },
        child: Column(children: [
          Expanded(
              child: _mainWidgets(context, viewStateProvider.viewerState,
                  appConfigProvider.appConfig)),
          Container(
              color: Colors.white,
              height: 42,
              child: _bottomBarWidget(context, viewStateProvider)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ViewerStateProvider, AppConfigProvider>(
        builder: (context, viewStateProvider, appConfigProvider, child) {
      var child = SizedBox(
          child: DropTarget(
              child: _bodyWidget(context, viewStateProvider, appConfigProvider),
              onDragDone: (details) {
                var files = details.files;
                if (files.isNotEmpty) {
                  var path = files[0].path;
                  viewStateProvider.dragImagePath(path);
                }
              }));
      return child;
    });
  }
}
