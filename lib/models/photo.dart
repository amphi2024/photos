import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amphi/utils/json_value_extractor.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photos/channels/app_method_channel.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:photos/models/app_settings.dart';
import 'app_storage.dart';

class Photo {

  static String generatedId(String path) {
    int length = Random().nextInt(5) + 10;

    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    String firstChar = chars[Random().nextInt(chars.length)];
    String secondChar = chars[Random().nextInt(chars.length)];

    String result = "$firstChar$secondChar";
    for (int i = 0; i < length; i++) {
      result += chars[Random().nextInt(chars.length)];
    }

    if(Directory(PathUtils.join(path, firstChar, secondChar ,result)).existsSync()) {
      return generatedId(path);
    }
    else {
      return result;
    }
  }

   String thumbnailPath = "";
   String path = "";
  String photoPath = "";

  String id;
  Map<String, dynamic> data = {};
  String title = "";
  List<String> tags = [];
  DateTime created;
  DateTime modified;
  DateTime date;
  DateTime? deleted;
  String mimeType = "";
  String sha256 = "";
  String? note;

  Photo({
    required this.id,
    this.title = "",
    DateTime? created,
    DateTime? modified,
    DateTime? date,
    this.deleted
  }) : created = created ?? DateTime.now(),
        modified = modified ?? DateTime.now(),
  date = date ?? DateTime.now();

  Photo.fromMap(Map<String, dynamic> data)
      : id = data["id"],
        title = data["title"],
        created = data.getDateTime("created"),
        modified = data.getDateTime("modified"),
        date = data.getDateTime("date"),
        deleted = data.getNullableDateTime("deleted"),
        mimeType = data["mime_type"] ?? data["mimeType"],
  sha256 = data["sha256"],
  note = data["note"] {
    final fileType = mimeType.split("/").last;
    photoPath = PathUtils.join(appStorage.libraryPath, id[0], id[1], id, "photo.$fileType");
    thumbnailPath = PathUtils.join(appStorage.libraryPath, id[0], id[1], id, "thumbnail.jpg");
  }

  void getPhotoPath() {
    final fileType = mimeType.split("/").last;
    photoPath = PathUtils.join(path, "photo.$fileType");
  }

  static Future<Photo> createdPhoto(String originalPath, WidgetRef ref) async {
    var id = generatedId(appStorage.libraryPath);

    var fileExtension = PathUtils.extension(originalPath);
    // final photo = Photo.fromId(id);
    final photo = Photo(id: "");
    var directory = Directory(photo.path);
    if(!await directory.exists()) {
      await directory.create(recursive: true);
    }
    var originalFile = File(originalPath);
    var photoFile = File(PathUtils.join(photo.path, "photo${fileExtension}"));
    var bytes = await originalFile.readAsBytes();
    await photoFile.writeAsBytes(bytes);

    photo.photoPath = photoFile.path;
    photo.title = PathUtils.basename(originalFile.path);
    photo.created = DateTime.now();
    photo.modified = DateTime.now();
    photo.date = DateTime.now();

    final fileType = fileExtension.split(".").last;
    if(isImageExtension(fileType)) {
      photo.mimeType = "image/$fileType";
    }
    else {
      photo.mimeType = "video/$fileType";
    }

    final digest = crypto.sha256.convert(bytes);
    photo.sha256 = digest.toString();

    await photo.save();
    appWebChannel.uploadPhoto(photo: photo, ref: ref);
    photo.generateThumbnail();
    return photo;
  }

  Future<bool> verifySha256() async {
    return verifySha256Isolate(photoPath, sha256);
  }

  Future<bool> verifySha256Isolate(String path, String expectedSha256) async {
    return await compute(_computeSha256, {'path': path, 'sha256': expectedSha256});
  }

  Future<bool> _computeSha256(Map<String, String> args) async {
    final path = args['path']!;
    final expectedSha256 = args['sha256']!;

    final file = File(path);
    if (!file.existsSync()) return false;

    final digest = await crypto.sha256.bind(file.openRead()).first;

    return digest.toString() == expectedSha256;
  }

  Future<void> save({bool upload = true}) async {
    final directory = Directory(path);
    if(!await directory.exists()) {
      await directory.create(recursive: true);
    }
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));
    if(upload && appSettings.useOwnServer) {
      await appWebChannel.uploadPhotoInfo(photo: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    final directory = Directory(path);
    if(await directory.exists()) {
      await directory.delete(recursive: true);
    }
    if(upload && appSettings.useOwnServer) {
      await appWebChannel.deletePhoto(photo: this);
    }
  }

  bool isImage() {
    return mimeType.startsWith("image");
  }

  Future<void> generateThumbnail() async {
    await appMethodChannel.generateThumbnail(this);
  }

  Future<void> deleteThumbnail() async {
    // final file = File(thumbnailPath);
    // if(await file.exists()) {
    //   await file.delete();
    // }
  }

}

bool isImageExtension(String fileExtension) {
  const videoExtensions = { "mp4", "mov", "avi", "wmv", "mkv", "flv", "webm", "mpeg", "mpg", "m4v", "3gp", "3g2", "f4v", "swf", "vob", "ts"};
  return !videoExtensions.contains(fileExtension);
}

extension DateExtension on DateTime {
  String toLocalizedString() {
    return "${DateFormat.yMMMMEEEEd().format(this)} | ${DateFormat.jm().format(this)}";
  }
}