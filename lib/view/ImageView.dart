import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:window_manager/window_manager.dart';
import '../model/ViewerState.dart';
import '../Controller/ViewerStateController.dart';
import './MetadataView.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  void initState() {
    super.initState();
  }

  Widget _getImageWidget(Uint8List? imageData) {
    if (imageData == null) {
      return const SizedBox.shrink();
    } else {
      return Image.memory(imageData,
          fit: BoxFit.contain, filterQuality: FilterQuality.medium);
    }
  }

  Widget _bodyWidget(BuildContext context) {
    var logger = SimpleLogger();

    ViewerStateController viewerStateController = ViewerStateController.to;
    ViewerState viewerState = viewerStateController.viewerState;

    var imageFilename = Path.basename(viewerState.curImagePath);
    windowManager.setTitle(imageFilename);

    Widget childWidget;

    final metaTable = viewerState.curImageMetaData.getMetaTable();

    var childWidgets = <Widget>[];
    childWidgets
        .add(Expanded(child: _getImageWidget(viewerState.curImageData)));
    childWidgets.add(const VerticalDivider());

    var sideItems = <Widget>[];

    sideItems.add(Text(viewerState.curImageMetaData.imageType));

    if (metaTable.isNotEmpty) {
      sideItems.add(MetadataView.build(context, metaTable));
    }

    var sideWidget = Container(
        padding: const EdgeInsets.fromLTRB(1, 10, 3, 10),
        width: 400,
        child: ListView(shrinkWrap: true, children: sideItems));

    childWidgets.add(sideWidget);

    childWidget = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: childWidgets);

    var buttonBarItems = <Widget>[
      IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            viewerStateController.getPreviousImage();
          }),
      Text(viewerStateController.getCurrentPositionText()),
      IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            viewerStateController.getNextImage();
          }),
    ];

    Widget buttonBar = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: viewerState.curImageIndex != -1
            ? buttonBarItems
            : const <Widget>[]);

    return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.runtimeType == RawKeyDownEvent) {
            switch (event.physicalKey) {
              case PhysicalKeyboardKey.arrowLeft:
                viewerStateController.getPreviousImage();
                break;
              case PhysicalKeyboardKey.arrowRight:
                viewerStateController.getNextImage();
                break;
            }
          }
        },
        child: Column(children: [
          Expanded(child: childWidget),
          Container(color: Colors.white, height: 42, child: buttonBar),
        ]));
    // return Container(color: Colors.grey, child: childWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewerStateController>(builder: (controller) {
      return _bodyWidget(context);
    });
  }
}
