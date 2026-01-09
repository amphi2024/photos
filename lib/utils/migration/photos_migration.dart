import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/app_storage.dart';

Future<void> migratePhotos(Database db) async {
  final batch = db.batch();
  var directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "photos"));
  if(!await directory.exists()) {
    return;
  }
  for (var subDirectory in directory.listSync()) {
    if (subDirectory is Directory) {
      for (var subDirectory2 in subDirectory.listSync()) {
        if (subDirectory2 is Directory) {
          for (var directory in subDirectory2.listSync()) {
            if (directory is Directory) {
              var id = PathUtils.basename(directory.path);
              var infoFile = File(PathUtils.join(directory.path, "info.json"));
              if (await infoFile.exists()) {
                Map<String, dynamic> map = jsonDecode(await infoFile.readAsString());

                var data = _parsedLegacyPhoto(id, map);
                batch.insert("photos", data);

              }
            }
          }
        }
      }
    }
  }

  await batch.commit();

  final libraryDirectory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "library"));
  if(await libraryDirectory.exists()) {
    try {
      for (var subDirectory in directory.listSync()) {
        if (subDirectory is Directory) {
          final directoryName = PathUtils.basename(subDirectory.path);
          await subDirectory.rename(PathUtils.join(appStorage.selectedUser.storagePath, "library", directoryName));
        }
      }
    }
    catch(e) {
      debugPrint(e.toString());
    }
  }
  else {
    await directory.rename(PathUtils.join(appStorage.selectedUser.storagePath, "library"));
  }
}

Map<String, dynamic> _parsedLegacyPhoto(String id, Map<String, dynamic> map) {
  return {
    "id": id,
    "title": map["title"] ?? "",
    "created": map["added"] ?? map["created"] ?? 0,
    "modified": map["modified"] ?? 0,
    "date": map["date"] ?? 0,
    "deleted": map["deleted"],
    "mime_type": map["mime_type"] ?? map["mimeType"] ?? "",
    "sha256": map["sha256"] ?? "",
    "note": map["note"],
    "tags": map["tags"]
  };
}