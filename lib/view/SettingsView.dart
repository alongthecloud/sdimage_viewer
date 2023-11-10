import 'dart:io';

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:easy_dialogs/easy_dialogs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class SettingsView extends StatefulWidget {
  SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Help")), body: _settingsUI(context));
  }

  String? _directoryPath;
  String? _fullFilePath;
  String? _filename;

  final List<String> _positionList = [
    "left-top",
    "left-bottom",
    "right-top",
    "right-bottom"
  ];

  int _positionIndex = 0;
  bool _watermarkEnabled = false;

  int _marginPt = 0;

  void _pickImageFiles(String title) async {
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
        setState(() {
          _fullFilePath = paths.files.first.path;
          _directoryPath = p.dirname(_fullFilePath!);
          _filename = p.basename(_fullFilePath!);
        });
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
    var watermarkSettingTiles = [
      SettingsTile.switchTile(
          initialValue: _watermarkEnabled,
          onToggle: (value) {
            setState(() {
              _watermarkEnabled = value;
            });
          },
          title: const Text('Watermark'))
    ];

    if (_watermarkEnabled) {
      watermarkSettingTiles.add(SettingsTile(
          leading: const Icon(Icons.subdirectory_arrow_right),
          title: const Text(' Position'),
          trailing: Wrap(children: [
            Text(_positionList[_positionIndex]),
            const Icon(Icons.navigate_next)
          ]),
          onPressed: (context) {
            showDialog(
                context: context,
                builder: (context) => SingleChoiceConfirmationDialog<String>(
                    title: const Text('Watermark Position'),
                    initialValue: _positionList[_positionIndex],
                    items: _positionList,
                    onSubmitted: (value) {
                      setState(() {
                        _positionIndex = _positionList.indexOf(value);
                        if (_positionIndex < 0) _positionIndex = 0;
                      });
                      debugPrint(value);
                    }));
          }));
      watermarkSettingTiles.add(SettingsTile(
        leading: const Icon(Icons.subdirectory_arrow_right),
        title: const Text(' Margin (px)'),
        trailing: Wrap(
            children: [Text("$_marginPt px"), const Icon(Icons.navigate_next)]),
        onPressed: (context) {
          _showTextInputDialog(
              context, "Margin(px)", "px", _marginPt.toString(), (value) {
            setState(() {
              _marginPt = int.parse(value);
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
                _fullFilePath != null
                    ? Image.file(File(_fullFilePath!), height: 52)
                    : const Icon(Icons.image),
                const Icon(Icons.navigate_next)
              ])),
          onPressed: (context) {
            _pickImageFiles("Watermark Image");
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
