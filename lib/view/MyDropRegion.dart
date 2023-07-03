import 'dart:async';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:sdimage_viewer/Controller/ViewerStateController.dart';
import 'package:sdimage_viewer/view/ImageView.dart';

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

  void _updateFileInfo(path) async {
    ViewerStateController.to.dragImagePath(path);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: DropTarget(
            onDragDone: (details) {
              var files = details.files;
              if (files.isNotEmpty) {
                _updateFileInfo(files[0].path);
              }
            },
            child: const ImageView()));
  }
}
