import 'dart:convert';

import 'package:amphi/utils/json_value_extractor.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:photos/models/photo.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../utils/generated_id.dart';
import 'app_settings.dart';

class Album {

  late String path;
  String id;
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


  Future<void> save({bool upload = true}) async {
    if (id.isEmpty) {
      id = await generatedAlbumId();
    }
    final database = await databaseHelper.database;
    await database.insert("photos", toSqlInsertMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      if(upload && appSettings.useOwnServer) {
        await appWebChannel.uploadAlbum(album: this);
      }
  }

  Future<void> delete({bool upload = true}) async {
    if(id.isEmpty) {
      return;
    }

    final database = await databaseHelper.database;
    await database.delete("albums", where: "id = ?", whereArgs: [id]);
    if (upload && appSettings.useOwnServer) {
      appWebChannel.deleteAlbum(album: this);
    }
  }

  Map<String, dynamic> _toMap() {
    return {
      "id": id,
      "title": title,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "cover_photo_index": coverPhotoIndex,
      "note": note
    };
  }

  Map<String, dynamic> toSqlInsertMap() {
    return {
      ..._toMap(),
      "photos": jsonEncode(photos)
    };
  }

  Map<String, dynamic> toJsonBody() {
    return {
      ..._toMap(),
      "photos": photos
    };
  }
}
