import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import '../model/AppPath.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Help")),
        body: Container(
            margin: const EdgeInsets.all(24), child: _helpDocument(context)));
  }

  String _getMarkdownDocument(BuildContext context) {
    String outputDirPath = AppPath().outputDirPath;
    String markdownDocument = """
  # About this app

  This app shows images generated by StableDiffusion (A1111) with meta-data.

  https://github.com/alongthecloud/sdimage_viewer

  ### Functions of buttons

  * ![help](icon://0e309) : Show this help.
  * ![settings](icon://0e57f) : Show the settings dialog.
  * ![save](icon://0e550) : Save the current image specific path.
    * output directory : $outputDirPath
  * Keyboard shortcuts 
    * The Left Arrow, Right Arrow, Home, and End Key moves to the previous image, next image, first image, and last image.
    * The Up arrow key moves to an image 10 steps previous, The Down arrow key moves to an image 10 steps next.

  ### Used flutter libraries
    clipboard,desktop_drop,expandable_text,flutter_markdown,get,image,oktoast,path_provider,settings_ui,simple_logger,url_launcher,window_manager

  """;

    return markdownDocument;
  }

  Widget _helpDocument(BuildContext context) {
    return Markdown(
        data: _getMarkdownDocument(context),
        imageBuilder: _imageBuilder,
        softLineBreak: true);
  }

  Widget _imageBuilder(Uri uri, String? title, String? alt) {
    var logger = SimpleLogger();
    logger.info("uri: $uri, title: $title, alt: $alt");

    String scheme = uri.scheme;
    if (scheme == "icon") {
      int? iconID = int.tryParse(uri.authority, radix: 16);
      if (iconID != null) {
        return Icon(IconData(iconID, fontFamily: 'MaterialIcons'));
      } else {
        return Text(uri.toString());
      }
    }

    return Text(alt ?? "undefined");
  }
}
