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
import '../model/DataManager.dart';
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

      final buttonBar = ButtonBarView(
          viewerState: viewStateProvider.viewerState, iconSize: 24);
      Widget leftWidget =
          _mainViewWidget(context, viewStateProvider.viewerState);
      Widget rightWidget =
          ImagePropertyView(viewerState: viewStateProvider.viewerState);

      Widget bottomWidget = Container(
          color: Colors.white,
          height: 42,
          child: _bottomBarWidget(context, viewStateProvider));

      return RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) => _onKeyEvent(event, viewStateProvider),
          child: SizedBox(
              child: DropTarget(
                  child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final ratio = width / height;
            final mobileLayout = (width < 720 || ratio < 0.8);
            if (mobileLayout) {
              return _mobileBody(
                  context, buttonBar, leftWidget, rightWidget, bottomWidget);
            } else {
              return _desktopBody(
                  context, buttonBar, leftWidget, rightWidget, bottomWidget);
            }
          }), onDragDone: (details) {
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
    var currentPositionText = viewStateProvider.getCurrentPositionText();

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
      Row(children: [SortByButton(), Text(currentPositionText)]),
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

  Widget _mainViewWidget(BuildContext context, ViewerState viewerState) {
    return Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 0, 1),
        child: ImageView(viewerState: viewerState));
  }

  Widget _desktopBody(BuildContext context, Widget buttonBar, Widget leftWidget,
      Widget rightWidget, Widget bottomWidget) {
    return Column(children: [
      Expanded(
          child: Row(
        children: [
          Expanded(
            child: leftWidget,
          ),
          const VerticalDivider(thickness: 1, width: 5),
          SizedBox(
            width: 380,
            child: Column(children: [buttonBar, rightWidget]),
          ),
        ],
      )),
      Container(color: Colors.white, height: 42, child: bottomWidget)
    ]);
  }

  Widget _mobileBody(BuildContext context, Widget buttonBar, Widget leftWidget,
      Widget rightWidget, Widget bottomWidget) {
    return Column(children: [
      Flexible(
          fit: FlexFit.tight,
          child: Stack(children: [
            leftWidget,
            buttonBar,
          ])),
      const Divider(height: 3, thickness: 1),
      rightWidget,
      bottomWidget,
    ]);
  }
}

class SortByButton extends StatelessWidget {
  const SortByButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewerStateProvider>(
        builder: (context, viewStateProvider, child) {
      var dataManager = viewStateProvider.viewerState.dataManager;

      var arrow = dataManager.sortDescending ? '↓' : '↑';
      var sortType = dataManager.sortType;

      return PopupMenuButton<String>(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sort by ${SortType.names[sortType]} $arrow'),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        onSelected: (String result) {
          var newSortType = int.parse(result);
          bool sortDescending = (dataManager.sortType == newSortType)
              ? !dataManager.sortDescending
              : dataManager.sortDescending;
          viewStateProvider.viewerState
              .changeSortType(newSortType, sortDescending);
          viewStateProvider.viewerState.updateImage().then((_) {
            viewStateProvider.update();
          });
        },
        itemBuilder: (BuildContext context) {
          var menuItems = <PopupMenuEntry<String>>[];
          for (int i = 0; i < SortType.names.length; i++) {
            menuItems.add(PopupMenuItem<String>(
                value: i.toString(),
                child: Text('Sort by ${SortType.names[i]}')));
          }

          return menuItems;
        },
      );
    });
  }
}
