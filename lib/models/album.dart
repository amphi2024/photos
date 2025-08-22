import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amphi/utils/path_utils.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:photos/models/photo.dart';

import 'app_settings.dart';
import 'app_storage.dart';

class Album {
  static String generatedId(String path) {
    int length = Random().nextInt(5) + 10;

    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    String result = "";
    for (int i = 0; i < length; i++) {
      result += chars[Random().nextInt(chars.length)];
    }

    if(Directory(PathUtils.join(path, result)).existsSync()) {
      return generatedId(path);
    }
    else {
      return result;
    }
  }

  static String getFilePathById(String filename) {
    return PathUtils.join(appStorage.albumsPath, filename);
  }

  late String path;
  String id;
  Map<String, dynamic> data = {};

  String get filename => data["filename"] ?? "";
  set filename(String value) => data["filename"] = value;

  String get title => data.putIfAbsent("title", () => "");
  set title(String value) => data["title"] = value;

  List<dynamic> get photos =>  data.putIfAbsent("photos", () => []);
  set photos(List<dynamic> value) => data["photos"] = value;

  List<dynamic> getVisiblePhotos(Map<String, Photo> photoMap) {
    return photos.where((id) => photoMap[id]?.deleted == null && photoMap.containsKey(id)).toList();
  }

  DateTime get created => DateTime.fromMillisecondsSinceEpoch(data.putIfAbsent("created", () => 0)).toLocal();
  set created(DateTime dateTime) {
    data["created"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data.putIfAbsent("modified", () => 0)).toLocal();
  set modified(DateTime dateTime) {
    data["modified"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  String get mimeType => data["mimeType"] ?? "";
  set mimeType(String value) => data["mimeType"] = value;

  String get sha256 => data["sha256"] ?? "";
  set sha256(String value) => data["sha256"] = value;

  Album.fromFilename(String filename, {Map<String, dynamic>? data}) : id = filename.split(".").first {
    path = PathUtils.join(appStorage.albumsPath, filename);
    if(data != null) {
      this.data = data;
    }
    else {
      final infoFile = File(path);
      if(infoFile.existsSync()) {
        try {
          this.data = jsonDecode(infoFile.readAsStringSync());
        }
        catch(e) {
          this.data = {};
        }
      }
    }
  }

  Future<void> save({bool upload = true}) async {
    final file = File(path);
    await file.writeAsString(jsonEncode(data));
    if(upload && appSettings.useOwnServer) {
      appWebChannel.uploadAlbum(album: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    final file = File(path);
    await file.delete();
    if(upload && appSettings.useOwnServer) {
      appWebChannel.deleteAlbum(album: this);
    }
  }

}