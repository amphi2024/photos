import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/utils/screen_size.dart';

import '../pages/photo/desktop_photo_page.dart';
import '../pages/photo/photo_page.dart';
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
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        if (isDesktop()) {
          return DesktopPhotoPage(id: photoId);
        }
        return const PhotoPage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}