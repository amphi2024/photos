import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/utils/screen_size.dart';

import '../providers/current_photo_id_provider.dart';

void onPhotoPressed({required WidgetRef ref, required String currentPhotoId, required String photoId, required BuildContext context, required List<String>? selectedItems}) {
  if(isDesktop() && selectedItems != null) {
    if(!ref.read(selectedItemsProvider.notifier).ctrlPressed) {
      ref.read(selectedItemsProvider.notifier).endSelection();
      return;
    }

    if(selectedItems.contains(photoId)) {
      ref.read(selectedItemsProvider.notifier).removeId(photoId);
    }
    else {
      ref.read(selectedItemsProvider.notifier).addId(photoId);
    }
    return;
  }

  if (currentPhotoId == photoId) {
    ref.read(currentPhotoIdProvider.notifier).set("");
  } else {
    ref.read(currentPhotoIdProvider.notifier).set(photoId);
  }
}