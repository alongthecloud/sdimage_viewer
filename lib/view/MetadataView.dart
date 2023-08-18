import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:oktoast/oktoast.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/MetaKeyword.dart';

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
      TableRow row = _tableRow(key, value);
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

  static TableRow _tableRow(String key, String value) {
    var logger = SimpleLogger();

    Widget keyWidget;
    Widget valueWidget;
    if (key == MetaKeyword.Prompt || key == MetaKeyword.Negative_prompt) {
      keyWidget = InkWell(
        onTap: () {
          FlutterClipboard.copy(value).then((value) {
            showToastWidget(Text("$key copied!",
                style:
                    TextStyle(backgroundColor: Colors.grey.withOpacity(0.5))));
            logger.info("$key copied!");
          });
        },
        child: Wrap(children: [
          Text(key,
              style: const TextStyle(decoration: TextDecoration.underline)),
        ]),
      );

      valueWidget = ExpandableText(value,
          expandOnTextTap: true,
          collapseOnTextTap: true,
          expandText: '',
          maxLines: 4);
    } else {
      keyWidget = Text(key);
      if (key == MetaKeyword.Model_hash) {
        valueWidget = InkWell(
          onTap: () {
            final Uri url = Uri.parse('https://civitai.com/?query=$value');
            launchUrl(url);
          },
          child: Wrap(children: [
            Text(value,
                style: const TextStyle(decoration: TextDecoration.underline)),
            const Icon(Icons.outbound_outlined, size: 18),
          ]),
        );
      } else if (key == MetaKeyword.Model) {
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
