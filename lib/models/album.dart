import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amphi/utils/json_value_extractor.dart';
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

    if (Directory(PathUtils.join(path, result)).existsSync()) {
      return generatedId(path);
    } else {
      return result;
    }
  }

  static String getFilePathById(String filename) {
    return PathUtils.join(appStorage.albumsPath, filename);
  }

  late String path;
  String id;
  Map<String, dynamic> data = {};
  String title = "";
  DateTime created;
  DateTime modified;
  DateTime? deleted;
  List<String> photos = [];
  int? coverPhotoIndex;
  String? note;

  Album({required this.id, this.title = "", DateTime? created, DateTime? modified, this.deleted})
      : created = created ?? DateTime.now(),
        modified = modified ?? DateTime.now();

  Album.fromMap(Map<String, dynamic> data)
      : id = data["id"],
        title = data["title"],
        created = data.getDateTime("created"),
        modified = data.getDateTime("modified"),
        deleted = data.getNullableDateTime("deleted"),
        photos = data.getStringList("photos"),
        note = data["note"],
        coverPhotoIndex = data["cover_photo_index"];

  List<dynamic> getVisiblePhotos(Map<String, Photo> photoMap) {
    return photos.where((id) => photoMap[id]?.deleted == null && photoMap.containsKey(id)).toList();
  }

  Album.fromFilename(String filename, {Map<String, dynamic>? data})
      : id = filename.split(".").first,
        created = DateTime.now(),
        modified = DateTime.now() {
    path = PathUtils.join(appStorage.albumsPath, filename);
    if (data != null) {
      this.data = data;
    } else {
      final infoFile = File(path);
      if (infoFile.existsSync()) {
        try {
          this.data = jsonDecode(infoFile.readAsStringSync());
        } catch (e) {
          this.data = {};
        }
      }
    }
  }

  Future<void> save({bool upload = true}) async {
    final file = File(path);
    await file.writeAsString(jsonEncode(data));
    if (upload && appSettings.useOwnServer) {
      appWebChannel.uploadAlbum(album: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    final file = File(path);
    await file.delete();
    if (upload && appSettings.useOwnServer) {
      appWebChannel.deleteAlbum(album: this);
    }
  }
}
