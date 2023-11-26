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

    List<SettingsSection> sections = [];
    if (_appConfig.general != null) {
      sections.add(_generalSettings(context, _appConfig.general!));
    }
    if (_appConfig.watermark != null) {
      sections.add(_watermarkSettings(context, _appConfig.watermark!));
    }

    return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: SettingsList(sections: sections));
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

  SettingsSection _generalSettings(BuildContext context, GeneralConfig config) {
    var settingsTiles = [
      SettingsTile.switchTile(
          initialValue: config.savewithmetatext,
          onToggle: (value) {
            setState(() {
              config.savewithmetatext = value;
            });
          },
          title: const Text('Save with meta text file')),
      SettingsTile(
        trailing: Wrap(children: [
          Text("${config.savefileprefix}"),
          const Icon(Icons.navigate_next)
        ]),
        title: const Text("Save file prefix"),
        onPressed: (value) {
          _showTextInputDialog(
              context, "Save file prefix", "prefix", config.savefileprefix,
              (value) {
            setState(() {
              config.savefileprefix = value;
            });
          });
        },
      )
    ];

    return SettingsSection(
      title: const Text("General"),
      tiles: settingsTiles,
    );
  }

  SettingsSection _watermarkSettings(
      BuildContext context, WaterMarkConfig config) {
    var watermarkSettingTiles = [
      SettingsTile.switchTile(
          initialValue: config.enable,
          onToggle: (value) {
            setState(() {
              config.enable = value;
            });
          },
          title: const Text('Watermark'))
    ];

    if (config.enable) {
      watermarkSettingTiles.add(SettingsTile(
          leading: const Icon(Icons.subdirectory_arrow_right),
          title: const Text(' Position'),
          trailing: Wrap(children: [
            Text(config.alignment.name),
            const Icon(Icons.navigate_next)
          ]),
          onPressed: (context) {
            showDialog(
                context: context,
                builder: (context) =>
                    SingleChoiceConfirmationDialog<ImageAlignment>(
                      title: const Text('Watermark Position'),
                      initialValue: config.alignment,
                      items: ImageAlignment.values,
                      onSubmitted: (value) {
                        var selectedAlignment = value;
                        setState(() {
                          config.alignment = selectedAlignment;
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
          Text("${config.margin} px"),
          const Icon(Icons.navigate_next)
        ]),
        onPressed: (context) {
          _showTextInputDialog(
              context, "Margin(px)", "px", config.margin.toString(), (value) {
            var marginPt = int.parse(value);
            if (marginPt < 0) marginPt = 0;
            setState(() {
              config.margin = marginPt;
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
                config.imagePath.isNotEmpty
                    ? Image.file(File(config.imagePath), height: 52)
                    : const Icon(Icons.image),
                const Icon(Icons.navigate_next)
              ])),
          onPressed: (context) {
            _pickImageFiles("Watermark Image", (pickedPath) {
              setState(() {
                config.imagePath = pickedPath;
              });
            });
          }));
    }

    return SettingsSection(
      title: const Text("Watermark"),
      tiles: watermarkSettingTiles,
    );
  }
}
