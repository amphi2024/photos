import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

  late String thumbnailPath;
  late String path;
  String id;
  String photoPath = "";
  Map<String, dynamic> data = {};

  String get title => data["title"] ?? "";
  set title(String value) => data["title"] = value;

  List<dynamic> get tags => data.putIfAbsent("tags", () => []);
  set tags(List<dynamic> value) => data["tags"] = value;

  DateTime get created => DateTime.fromMillisecondsSinceEpoch(data["created"] ?? 0).toLocal();
  set created(DateTime dateTime) {
    data["created"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data["modified"] ?? 0).toLocal();
  set modified(DateTime dateTime) {
    data["modified"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(data["date"] ?? 0).toLocal();
  set date(DateTime dateTime) {
    data["date"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  DateTime? get deleted {
    var value = data["deleted"];
    if(value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    return null;
  }

  set deleted(DateTime? dateTime) {
    if(dateTime == null) {
      data.remove("deleted");
    }
    else {
      data["deleted"] = dateTime.toUtc().millisecondsSinceEpoch;
    }
  }

  String get mimeType => data["mimeType"] ?? "";
  set mimeType(String value) => data["mimeType"] = value;

  String get sha256 => data["sha256"] ?? "";
  set sha256(String value) => data["sha256"] = value;

  String get note => data.putIfAbsent("note", () => "");
  set note(String value) => data["note"] = value;

  static String getFilePathById(String filename) {
    return PathUtils.join(appStorage.photosPath, filename.substring(0, 1), filename.substring(1, 2), filename);
  }

  Photo.fromId(this.id, {Map<String, dynamic>? data}) {
    if(id.length < 2) {
      path = "";
    }
    else {
      path = PathUtils.join(appStorage.photosPath, id.substring(0, 1), id.substring(1, 2) , id);
    }
    if(data != null) {
      this.data = data;
      getPhotoPath();
    }
    else {
      final infoFile = File(PathUtils.join(path, "info.json"));
      if(infoFile.existsSync()) {
        try {
          this.data = jsonDecode(infoFile.readAsStringSync());
          getPhotoPath();
        }
        catch(e) {
          photoPath = PathUtils.join(path, "photo");
        }
      }
      else {
        photoPath = PathUtils.join(path, "photo");
      }
    }
    thumbnailPath = PathUtils.join(path, "thumbnail.jpg");
  }

  void getPhotoPath() {
    final fileType = mimeType.split("/").last;
    photoPath = PathUtils.join(path, "photo.$fileType");
  }

  static Future<Photo> createdPhoto(String originalPath, WidgetRef ref) async {
    var id = generatedId(appStorage.photosPath);

    var fileExtension = PathUtils.extension(originalPath);
    final photo = Photo.fromId(id);
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
    await appWebChannel.uploadPhoto(photo: photo, ref: ref);
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