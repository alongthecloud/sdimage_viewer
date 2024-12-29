import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:expandable_text/expandable_text.dart';
import '../model/ViewerState.dart';
import '../util/WidgetUtil.dart';
import '../util/Util.dart';
import '../util/MetaKeyword.dart';

class ImagePropertyView extends StatelessWidget {
  final ViewerState viewerState;

  ImagePropertyView({Key? key, required this.viewerState}) : super(key: key);

  static Widget _tableView(BuildContext context, Map<String, String> table) {
    var rows = <TableRow>[];
    table.forEach((key, value) {
      TableRow row = _tableRow(context, key, value);
      rows.add(row);
    });

    var logger = SimpleLogger();
    logger.info("Meta size : ${rows.length}");

    return Table(
        children: rows,
        border:
            TableBorder.all(color: Colors.black.withAlpha(0x33), width: 0.5),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.8),
        });
  }

  static TableRow _tableRow(BuildContext context, String key, String value) {
    Widget keyWidget;
    Widget valueWidget;

    final String lowerKey = key.toLowerCase();
    if (lowerKey.contains("prompt") || lowerKey.contains("cliptext")) {
      keyWidget = InkWell(
          child: Wrap(children: [WidgetUtil.ContentCopyIcon, Text(key)]),
          onTap: () {
            Util.copy2clipboard(context, key, value);
          });

      valueWidget = ExpandableText(value,
          expandOnTextTap: true,
          collapseOnTextTap: true,
          expandText: '',
          maxLines: 4);
    } else {
      keyWidget = Text(key);
      valueWidget = SelectableText(value);
    }

    return TableRow(children: [
      keyWidget,
      valueWidget,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var metaTable = viewerState.curImageMetaData.getMetaTable();

    List<Widget> sideItems = [];
    if (viewerState.curImageData != null) {
      var imageSizeText = '${viewerState.curImageMetaData.imageType} ('
          '${viewerState.curImageData!.width} x '
          '${viewerState.curImageData!.height})';

      sideItems.add(Text(imageSizeText));
      sideItems.add(const Divider(thickness: 0.1));
    }

    if (metaTable.isNotEmpty) {
      sideItems.add(InkWell(
          child: Wrap(
              children: [WidgetUtil.ContentCopyIcon, const Text("Meta-data")]),
          onTap: () {
            var value = viewerState.curImageMetaData.toJson(true);
            Util.copy2clipboard(context, "Meta-data", value);
          }));

      var metaTableWidget = Container(
          margin: const EdgeInsets.all(4),
          child: Align(
              alignment: Alignment.topCenter,
              child: _tableView(context, metaTable)));

      sideItems.add(metaTableWidget);
    }

    return Expanded(
      child: Container(
          padding: const EdgeInsets.all(4),
          child: ListView(shrinkWrap: true, children: sideItems)),
    );
  }
}
