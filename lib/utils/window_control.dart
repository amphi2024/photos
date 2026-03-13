import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:photos/models/app_cache.dart';
import 'package:window_manager/window_manager.dart';

Future<void> saveWindowSize() async {
  if(Platform.isWindows || Platform.isMacOS) {
    appCacheData.windowWidth = appWindow.size.width;
    appCacheData.windowHeight = appWindow.size.height;
  }
  else {
    final size = await windowManager.getSize();
    appCacheData.windowWidth = size.width;
    appCacheData.windowHeight = size.height;
  }
  await appCacheData.save();
}

void minimize() {
  windowManager.minimize();
}

void maximizeOrRestore() async {
  if (!(await windowManager.isMaximizable())) {
    windowManager.unmaximize();
  } else {
    windowManager.maximize();
  }
}

void close() async {
  await saveWindowSize();
  windowManager.close();
}