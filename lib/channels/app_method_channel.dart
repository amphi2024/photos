import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:photos/models/photo.dart';

import '../models/app_settings.dart';

final appMethodChannel = AppMethodChannel.getInstance();

class AppMethodChannel extends MethodChannel {
  static final AppMethodChannel _instance = AppMethodChannel._internal("photos_method_channel");

  AppMethodChannel._internal(super.name) {
    setMethodCallHandler((call) async {
      switch (call.method) {
        default:
          break;
      }
    });
  }

  int systemVersion = 0;

  static AppMethodChannel getInstance() => _instance;

  void setNavigationBarColor(Color color) {
    if (Platform.isAndroid) {
      invokeMethod("set_navigation_bar_color", {"color": color.value, "transparent_navigation_bar": appSettings.transparentNavigationBar});
    }
  }

  Future<void> generateThumbnail(Photo photo) async {
    if(Platform.isLinux) {
      if(photo.isImage()) {
        Process.start(
          "magick",
          ["convert", "${photo.photoPath}[0]", '-resize', '300x300', photo.thumbnailPath]
        );
      }
      else {
        Process.start(
          "ffmpeg",
          ['-y', '-i', photo.photoPath, "-ss", "00:00:05", "-vframes", "1", "-vf", "scale=-2:720", photo.thumbnailPath]
        );
      }
    }
    else if(Platform.isWindows) {
      if (photo.isImage()) {
        Process.start(
          r'.\ffmpeg.exe',
          ['-i', photo.photoPath, '-vf', 'scale=300:-1', photo.thumbnailPath],
        );
      } else {
        Process.start(
          r'.\ffmpeg.exe',
          ['-y', '-i', photo.photoPath, '-ss', '00:00:05', '-vframes', '1', '-vf', 'scale=-2:720', photo.thumbnailPath],
        );
      }
    }
    else {
      await invokeMethod("generate_thumbnail", {"file_path": photo.photoPath, "thumbnail_path": photo.thumbnailPath});
    }
  }

  Future<void> getSystemVersion() async {
    systemVersion = await invokeMethod("get_system_version");
  }
}
