import 'dart:math';
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