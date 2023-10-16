import 'dart:async';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import './ImageView.dart';
import '../provider/ViewStateProvider.dart';

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

  void _updateFileInfo(context, path) async {
    var viewStateProvider =
        Provider.of<ViewStateProvider>(context, listen: false);
    viewStateProvider.dragImagePath(path);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: DropTarget(onDragDone: (details) {
      var files = details.files;
      if (files.isNotEmpty) {
        _updateFileInfo(context, files[0].path);
      }
    }, child: Consumer<ViewStateProvider>(builder: (context, value, child) {
      return ImageView();
    })));
  }
}
