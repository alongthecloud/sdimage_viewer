import 'dart:io';

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:easy_dialogs/easy_dialogs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../model/AppConfig.dart';
import '../ImageAlignment.dart';

// ignore: must_be_immutable
class SettingsView extends StatefulWidget {
  SettingsView({super.key, required this.appConfig});

  AppConfig appConfig;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late AppConfig _appConfig;

  String? _directoryPath;
  String? _filename;

  @override
  void initState() {
    super.initState();

    _appConfig = widget.appConfig;
  }

  @override
  Widget build(BuildContext context) {
    var watermarkconfig = _appConfig.watermark;
    if (watermarkconfig != null && watermarkconfig.imagePath.isNotEmpty) {
      var fullFilePath = watermarkconfig.imagePath;
      _directoryPath = p.dirname(fullFilePath);
      _filename = p.basename(fullFilePath);
    }

    return Scaffold(
        appBar: AppBar(title: const Text("Help")), body: _settingsUI(context));
  }

  void _pickImageFiles(String title, Function(String) onPickFile) async {
    try {
      FilePickerResult? paths = (await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) =>
            debugPrint(status.toString()),
        dialogTitle: title,
        initialDirectory: _directoryPath,
      ));

      if (paths != null) {
        onPickFile(paths.files.first.path!);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _showTextInputDialog(BuildContext context, String title,
      String hintText, String initialText, Function(String) onSubmit) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextFormField(
              initialValue: initialText,
              onChanged: (value) {},
              decoration: InputDecoration(hintText: hintText),
              onFieldSubmitted: (value) => onSubmit(value),
            ),
          );
        });
  }

  Widget _settingsUI(BuildContext context) {
    var watermarkconfig = _appConfig.watermark;
    if (watermarkconfig != null) const SizedBox.shrink();

    var watermarkSettingTiles = [
      SettingsTile.switchTile(
          initialValue: watermarkconfig!.enable,
          onToggle: (value) {
            setState(() {
              watermarkconfig.enable = value;
            });
          },
          title: const Text('Watermark'))
    ];

    if (watermarkconfig.enable) {
      watermarkSettingTiles.add(SettingsTile(
          leading: const Icon(Icons.subdirectory_arrow_right),
          title: const Text(' Position'),
          trailing: Wrap(children: [
            Text(watermarkconfig.alignment.name),
            const Icon(Icons.navigate_next)
          ]),
          onPressed: (context) {
            showDialog(
                context: context,
                builder: (context) =>
                    SingleChoiceConfirmationDialog<ImageAlignment>(
                      title: const Text('Watermark Position'),
                      initialValue: watermarkconfig.alignment,
                      items: ImageAlignment.values,
                      onSubmitted: (value) {
                        var selectedAlignment = value;
                        setState(() {
                          watermarkconfig.alignment = selectedAlignment;
                        });
                        debugPrint(selectedAlignment.toString());
                      },
                      itemBuilder: (item) {
                        return Text(item.name);
                      },
                    ));
          }));
      watermarkSettingTiles.add(SettingsTile(
        leading: const Icon(Icons.subdirectory_arrow_right),
        title: const Text(' Margin (px)'),
        trailing: Wrap(children: [
          Text("${watermarkconfig.margin} px"),
          const Icon(Icons.navigate_next)
        ]),
        onPressed: (context) {
          _showTextInputDialog(
              context, "Margin(px)", "px", watermarkconfig.margin.toString(),
              (value) {
            var marginPt = int.parse(value);
            if (marginPt < 0) marginPt = 0;
            setState(() {
              watermarkconfig.margin = marginPt;
            });
          });
        },
      ));
      watermarkSettingTiles.add(SettingsTile(
          leading: const Icon(Icons.subdirectory_arrow_right),
          title: const Text(' Image'),
          trailing: Container(
              padding: const EdgeInsets.all(4),
              child: Wrap(spacing: 8, children: [
                Text(_filename ?? ''),
                watermarkconfig.imagePath.isNotEmpty
                    ? Image.file(File(watermarkconfig.imagePath), height: 52)
                    : const Icon(Icons.image),
                const Icon(Icons.navigate_next)
              ])),
          onPressed: (context) {
            _pickImageFiles("Watermark Image", (pickedPath) {
              setState(() {
                watermarkconfig.imagePath = pickedPath;
              });
            });
          }));
    }

    return SettingsList(
      sections: [
        SettingsSection(
          tiles: watermarkSettingTiles,
        ),
      ],
    );
  }
}
