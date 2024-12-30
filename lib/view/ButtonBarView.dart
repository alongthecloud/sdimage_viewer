import 'package:flutter/material.dart';
import '../model/ViewerState.dart';
import '../ExternalToolExec.dart';
import 'HelpView.dart';

class ButtonBarView extends StatelessWidget {
  final ViewerState viewerState;
  final double iconSize;

  const ButtonBarView(
      {super.key, required this.viewerState, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    iconButton(IconData iconData, VoidCallback onPressed) {
      var icon = Icon(iconData);
      return IconButton(
          autofocus: true,
          iconSize: iconSize,
          onPressed: onPressed,
          icon: icon,
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white, // <-- Button color
            foregroundColor: Colors.blueGrey, // <-- Splash color
          ));
    }

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8.0,
            overflowAlignment: OverflowBarAlignment.end,
            children: [
              // open folder button
              iconButton(Icons.open_in_browser, () async {
                ExternalToolExec.openShell(viewerState.curImagePath);
              }),
              // help button
              iconButton(Icons.help, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HelpView()));
              })
            ]));
  }
}
