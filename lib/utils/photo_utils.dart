import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/photo.dart';

void createPhotos(WidgetRef ref) async {
        final selectedFiles = await FilePicker.platform.pickFiles(
          allowedExtensions: [
            "webp", "jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "svg",
            "ico", "heic", "heif", "jfif", "pjpeg", "pjp", "avif",
            "raw", "dng", "cr2", "nef", "arw", "rw2", "orf", "sr2", "raf", "pef",
            "mp4", "mov", "avi", "wmv", "mkv", "flv", "webm", "mpeg", "mpg", "m4v", "3gp", "3g2", "f4v", "swf", "vob", "ts"
          ],
          allowMultiple: true,
          type: FileType.custom
        );
        final xFiles = selectedFiles?.xFiles;
        if(xFiles != null) {
          for(var xFile in xFiles) {
            var path = xFile.path;
            xFile.mimeType;
            var photo = await Photo.createdPhoto(path, ref);
            ref.read(photosProvider.notifier).insertPhoto(photo);
          }
        }
}

void sharePhoto(Photo photo) async {
  final params = ShareParams(
    files: [XFile(photo.photoPath)],
  );

  await SharePlus.instance.share(params);
}

void exportPhoto(Photo photo) async {
  File originalFile = File(photo.photoPath);
  var bytes = await originalFile.readAsBytes();
  await FilePicker.platform.saveFile(
      fileName: "${photo.title}.${photo.mimeType.split("/").last}",
      bytes: bytes
  );
}