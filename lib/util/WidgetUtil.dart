import 'dart:io';
import 'package:flutter/material.dart';

class WidgetUtil {
  static Widget basicHelloWorldWidget(
      BuildContext context, List<String> texts) {
    return ListView.builder(
      itemCount: texts.length,
      itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(4), child: Text(texts[index])),
    );
  }

  static Widget roundWidget(Widget widget, double radius) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius), child: widget);
  }

  static Widget iconButton(Widget icon, Widget label, Function onTapFunc) {
    return Wrap(children: [
      InkWell(
        onTap: () {
          onTapFunc();
        },
        child: icon,
      ),
      label,
    ]);
  }

  static Widget ContentCopyIcon = Container(
      padding: const EdgeInsets.all(2),
      child: const Icon(Icons.content_copy, size: 15));
}
