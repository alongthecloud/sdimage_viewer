import 'dart:ui';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdimage_viewer/provider/AppConfigProvider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:expandable_text/expandable_text.dart';
import '../model/ViewerState.dart';
import '../util/WidgetUtil.dart';
import '../util/Util.dart';
import '../util/ImageUtil.dart';
import '../util/MetaKeyword.dart';
import './HelpView.dart';
import './SettingsView.dart';

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
    var copyEnableKeywords = [MetaKeyword.Prompt, MetaKeyword.Negative_prompt];

    Widget keyWidget;
    Widget valueWidget;

    if (copyEnableKeywords.contains(key)) {
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
    var appConfig = appConfigProvider.appConfig;
    var appUserData = appConfig.appUserData;

    getOffsetAndPath() {
      // calc offset
      var currentImage = viewerState.curImageData;
      Offset offset = Offset.zero;
      if (appUserData.waterMarkImage != null && currentImage != null) {
        var watermarkconfig = appConfig.watermark;
        if (watermarkconfig != null) {
          var wmImage = appUserData.waterMarkImage!;
          var margin = appConfig.watermark!.margin.toDouble();

          offset = ImageUtil.calcAlignmentOffset(
              appConfig.watermark!.alignment,
              Size(wmImage.width.toDouble(), wmImage.height.toDouble()),
              Size(currentImage.width.toDouble(),
                  currentImage.height.toDouble()),
              Offset(margin, margin));
        }
      }

      String prefix = '';
      if (appConfig.general != null) {
        prefix = appConfig.general!.savefileprefix;
      }

      String targetPath = ImageUtil.getImageFullPath(
          appConfig.outputDirPath, viewerState.curImagePath, prefix);

      return (offset, targetPath);
    }

    Widget rightButtonBar = ButtonBar(children: [
      IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            var offsetAndPath = getOffsetAndPath();
            var offset = offsetAndPath.$1;
            var targetPath = offsetAndPath.$2;

            ImageUtil.saveImageWithWatermark(
                    targetPath,
                    viewerState.curImageData,
                    appUserData.waterMarkImage,
                    offset)
                .then((result) async {
              if (result == true) {
                Util.showToastMessage(
                    context, "Image saved !", const Duration(seconds: 1));

                if (appConfig.general != null &&
                    appConfig.general!.savewithmetatext) {
                  StringBuffer sb = StringBuffer();
                  sb.writeln("original file : ${viewerState.curImagePath}");

                  File f = File(viewerState.curImagePath);
                  // bool exist = f.existsSync();
                  var modifiedTime = await f.lastModified();
                  sb.writeln("modify datetime : ${modifiedTime.toString()}");
                  sb.writeln("meta : ${metaTable.toString()}");

                  var metaFilePath =
                      "${path.withoutExtension(targetPath)}.meta.txt";

                  Util.saveTextFile(sb.toString(), metaFilePath);
                }
              }
            });
          }),
      IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SettingsView(appConfig: appConfigProvider.appConfig);
            })).then((value) {
              appConfigProvider.save();
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
      sideItems.add(InkWell(
          child: Wrap(
              children: [WidgetUtil.ContentCopyIcon, const Text("Meta-data")]),
          onTap: () {
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
