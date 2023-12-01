import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/AppPath.dart';
import '../model/ViewerState.dart';
import '../provider/AppConfigProvider.dart';
import '../util/ImageUtil.dart';
import '../util/Util.dart';
import 'HelpView.dart';
import 'SettingsView.dart';

class ButtonBarView extends StatelessWidget {
  final ViewerState viewerState;

  ButtonBarView({required this.viewerState});

  @override
  Widget build(BuildContext context) {
    var metaData = viewerState.curImageMetaData;

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

      var appPath = AppPath();

      String targetPath = ImageUtil.getImageFullPath(
          appPath.outputDirPath, viewerState.curImagePath, prefix);

      return (offset, targetPath);
    }

    var buttonShape = const CircleBorder();
    var buttonColor = Colors.blueGrey;

    return ButtonBar(alignment: MainAxisAlignment.end, children: [
      MaterialButton(
          color: buttonColor,
          shape: buttonShape,
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
                  sb.writeln("meta : \n${metaData.toJson(true)}");

                  var metaFilePath =
                      "${path.withoutExtension(targetPath)}.meta.txt";

                  Util.saveTextFile(sb.toString(), metaFilePath);
                }
              }
            });
          },
          child: const Icon(Icons.save)),
      MaterialButton(
          color: buttonColor,
          shape: buttonShape,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SettingsView(appConfig: appConfigProvider.appConfig);
            })).then((value) {
              appConfigProvider.save();
              appConfigProvider.update();
              return null;
            });
          },
          child: const Icon(Icons.settings)),
      MaterialButton(
          color: buttonColor,
          shape: buttonShape,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HelpView()));
          },
          child: const Icon(Icons.help)),
    ]);
  }
}
