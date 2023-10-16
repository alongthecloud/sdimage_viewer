import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:window_manager/window_manager.dart';
import '../provider/ViewStateProvider.dart';
import '../model/ViewerState.dart';
import './MetadataView.dart';
import './HelpView.dart';

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

  Widget _getImageWidget(ui.Image? image) {
    if (image == null) {
      return const SizedBox.shrink();
    } else {
      return RawImage(
          image: image, fit: BoxFit.contain, filterQuality: FilterQuality.high);
    }
  }

  Widget _bodyWidget(BuildContext context) {
    var logger = SimpleLogger();

    ViewStateProvider viewStateProvider =
        Provider.of<ViewStateProvider>(context, listen: false);
    ViewerState viewerState = viewStateProvider.viewerState;

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
        child: Column(children: [
          ButtonBar(children: [
            IconButton(
                icon: const Icon(Icons.help),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpView()));
                }),
          ]),
          const SizedBox(height: 4),
          ListView(shrinkWrap: true, children: sideItems),
        ]));

    childWidgets.add(sideWidget);

    childWidget = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: childWidgets);

    var buttonBarItems = <Widget>[
      IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            viewStateProvider.getPreviousImage();
          }),
      Text(viewStateProvider.getCurrentPositionText()),
      IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            viewStateProvider.getNextImage();
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
                viewStateProvider.getPreviousImage();
                break;
              case PhysicalKeyboardKey.arrowRight:
                viewStateProvider.getNextImage();
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
    return _bodyWidget(context);
  }
}
