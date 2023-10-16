// ref : https://bitbucket.org/closescreen/watch_recursively/src/master/lib/src/watch_recursively_base.dart

import 'dart:async' as asy;
import 'dart:io';

extension WatchingRecursively on Directory {
  Future<Stream<FileSystemEvent>> watchRecursively(
      {int events = FileSystemEvent.all, bool followLinks = true}) async {
    var controller = asy.StreamController<FileSystemEvent>();

    watch(events: events, recursive: false).listen((e) => controller.add(e));

    var dirs = list(recursive: true, followLinks: followLinks)
        .where((e) => e is Directory);

    await for (var dir in dirs) {
      dir.watch().listen((e) => controller.add(e));
    }

    return controller.stream;
  }
}
