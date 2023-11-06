import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:oktoast/oktoast.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/MetaKeyword.dart';
import '../util/WidgetUtil.dart';
import '../util/Util.dart';

class MetadataView {
  static Widget build(BuildContext context, Map<String, String> metaTable) {
    assert(metaTable.isNotEmpty);
    return Container(
        margin: const EdgeInsets.all(4),
        child: Align(
            alignment: Alignment.topCenter,
            child: _tableView(context, metaTable)));
  }

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
            TableBorder.all(color: Colors.black.withOpacity(0.3), width: 0.3),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.8),
        });
  }

  static TableRow _tableRow(BuildContext context, String key, String value) {
    Widget keyWidget;
    Widget valueWidget;
    if (key == MetaKeyword.Prompt || key == MetaKeyword.Negative_prompt) {
      keyWidget =
          WidgetUtil.iconButton(WidgetUtil.ContentCopyIcon, Text(key), () {
        Util.copy2clipboard(context, key, value);
      });

      valueWidget = ExpandableText(value,
          expandOnTextTap: true,
          collapseOnTextTap: true,
          expandText: '',
          maxLines: 4);
    } else {
      keyWidget = Text(key);
      if (key == MetaKeyword.Model) {
        valueWidget =
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold));
      } else {
        valueWidget = Text(value);
      }
    }

    return TableRow(children: [
      keyWidget,
      valueWidget,
    ]);
  }
}
