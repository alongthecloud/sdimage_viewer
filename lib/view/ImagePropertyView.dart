import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdimage_viewer/provider/AppConfigProvider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:expandable_text/expandable_text.dart';
import '../model/ViewerState.dart';
import '../model/AppConfig.dart';
import './HelpView.dart';
import './SettingsView.dart';
import '../util/WidgetUtil.dart';
import '../util/Util.dart';
import '../util/MetaKeyword.dart';

class ImagePropertyView extends StatelessWidget {
  final ViewerState viewerState;

  const ImagePropertyView({Key? key, required this.viewerState})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    var metaTable = viewerState.curImageMetaData.getMetaTable();
    var appConfigProvider =
        Provider.of<AppConfigProvider>(context, listen: false);

    Widget rightButtonBar = ButtonBar(children: [
      IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SettingsView(appConfig: appConfigProvider.appConfig);
            })).then((value) {
              appConfigProvider.update();
              return null;
            });
          }),
      IconButton(
          icon: const Icon(Icons.help),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HelpView()));
          }),
    ]);

    List<Widget> sideItems = [];
    if (viewerState.curImageData != null) {
      var imageSizeText = '${viewerState.curImageMetaData.imageType} ('
          '${viewerState.curImageData!.width} x '
          '${viewerState.curImageData!.height})';

      sideItems.add(Text(imageSizeText));
      sideItems.add(const Divider(thickness: 0.1));
    }

    if (metaTable.isNotEmpty) {
      sideItems.add(WidgetUtil.iconButton(
          WidgetUtil.ContentCopyIcon, const Text("Meta-data"), () {
        var value = metaTable.toString();
        Util.copy2clipboard(context, "Meta-data", value);
      }));

      var metaTableWidget = Container(
          margin: const EdgeInsets.all(4),
          child: Align(
              alignment: Alignment.topCenter,
              child: _tableView(context, metaTable)));

      sideItems.add(metaTableWidget);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(1, 10, 3, 10),
      width: 380,
      child: Column(children: [
        rightButtonBar,
        const SizedBox(height: 4),
        Expanded(
          child: ListView(shrinkWrap: true, children: sideItems),
        ),
      ]),
    );
  }
}
