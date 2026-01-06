import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/app_storage.dart';

Future<void> migrateAlbums(Database db) async {
  final batch = db.batch();
  var directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "albums"));
  if(!await directory.exists()) {
    return;
  }
  for (var file in directory.listSync()) {
    if (file is File) {
      final id = PathUtils.basenameWithoutExtension(file.path);
      Map<String, dynamic> map = jsonDecode(await file.readAsString());

      var data = _parsedLegacyAlbum(id, map);
      batch.insert("albums", data);
    }
  }

  await batch.commit();
}

Map<String, dynamic> _parsedLegacyAlbum(String id, Map<String, dynamic> map) {
  final photos = map["photos"];
  return {
    "id": id,
    "title": map["title"] ?? "",
    "created": map["created"] ?? 0,
    "modified": map["modified"] ?? 0,
    "deleted": map["deleted"],
    "photos": jsonEncode(photos is List<dynamic> ? photos : []),
    "cover_photo_index": map["cover_photo_index"],
    "note": map["note"]
  };
}