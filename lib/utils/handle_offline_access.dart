import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_storage.dart';

import '../channels/app_web_channel.dart';
import '../providers/photos_provider.dart';
import '../providers/providers.dart';

void makePhotosAvailableOffline(WidgetRef ref) {
  final selectedPhotos = ref.watch(selectedItemsProvider);
  if (selectedPhotos != null) {
    for (var id in selectedPhotos) {
      appWebChannel.downloadPhotoFile(photo: ref.read(photosProvider).photos.get(id), ref: ref);
    }
  }
}

void makePhotosOnlineOnly({required WidgetRef ref, required List<String> selectedItems}) {

    for (var id in selectedItems) {
      final photo = ref.read(photosProvider).photos.get(id);
      var file = File(photo.photoPath);
      if(photo.photoPath.startsWith(appStorage.selectedUser.storagePath)) {
        file.delete();
      }

      photo.availableOnOffline = false;
      ref.read(photosProvider.notifier).insertPhoto(photo);
      // TODO: Optimize it instead of calling insertPhoto in a for loop
    }
}