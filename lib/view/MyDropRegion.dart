import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../provider/ViewStateProvider.dart';
import '../model/ViewerState.dart';
import './ImagePropertyView.dart';
import './ImageView.dart';

class MyDropRegion extends StatefulWidget {
  const MyDropRegion({Key? key}) : super(key: key);

  @override
  State<MyDropRegion> createState() => _MyDropRegion();
}

class _MyDropRegion extends State<MyDropRegion> {
  @override
  void initState() {
    super.initState();
  }

  Widget _bottomBarWidget(
      BuildContext context, ViewStateProvider viewStateProvider) {
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
      BuildContext context, ViewStateProvider viewStateProvider) {
    ViewerState viewerState = viewStateProvider.viewerState;
    // left to right
    var childWidgets = [
      Expanded(
          child: Container(
              margin: const EdgeInsets.fromLTRB(1, 1, 0, 1),
              child: ImageView(viewerState: viewerState))),
      const VerticalDivider(thickness: 1, width: 5),
      ImagePropertyView(viewerState: viewerState)
    ]; // return Container(color: Colors.grey, child: childWidget);
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: childWidgets);
  }

  Widget _bodyWidget(
      BuildContext context, ViewStateProvider viewStateProvider) {
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
          Expanded(child: _mainWidgets(context, viewStateProvider)),
          Container(
              color: Colors.white,
              height: 42,
              child: _bottomBarWidget(context, viewStateProvider)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    var viewStateProvider =
        Provider.of<ViewStateProvider>(context, listen: false);

    return SizedBox(
        child: DropTarget(onDragDone: (details) {
      var files = details.files;
      if (files.isNotEmpty) {
        var path = files[0].path;
        viewStateProvider.dragImagePath(path);
      }
    }, child: Consumer<ViewStateProvider>(builder: (context, value, child) {
      return _bodyWidget(context, viewStateProvider);
    })));
  }
}
