import 'dart:io';
import 'dart:math';
import 'package:amphi/utils/path_utils.dart';
import 'package:photos/models/app_storage.dart';

import '../database/database_helper.dart';

Future<String> _generatedId(String table) async {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  final random = Random();
  while(true) {
    var length = random.nextInt(5) + 15;
    final id = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();

    final res = await (await databaseHelper.database).rawQuery('SELECT 1 FROM $table WHERE id = ? LIMIT 1;', [id]);
    if (res.isEmpty) {
      return id;
    }
  }
}

Future<String> generatedPhotoId() => _generatedId("photos");
Future<String> generatedAlbumId() => _generatedId("albums");
Future<String> generatedThemeId() => _generatedId("themes");

Future<String> generatedCsdThemeId() async {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  final random = Random();
  while(true) {
    var length = random.nextInt(5) + 15;
    final id = List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();

    final file = File(PathUtils.join(appStorage.selectedUser.storagePath, "window_button_themes", id));
    if(!await file.exists()) {
      return id;
    }
  }
}