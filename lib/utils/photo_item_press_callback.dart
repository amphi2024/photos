import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/photo.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/utils/screen_size.dart';

import '../pages/photo/desktop_photo_page.dart';
import '../pages/photo/photo_page.dart';
import '../providers/current_photo_id_provider.dart';

void onPhotoPressed({required WidgetRef ref, required String currentPhotoId, required Photo photo, required BuildContext context, required List<String>? selectedItems}) {
  if(selectedItems != null) {
    if(isDesktop()) {
      if(!ref.read(selectedItemsProvider.notifier).ctrlPressed) {
        ref.read(selectedItemsProvider.notifier).endSelection();
        return;
      }

      if(selectedItems.contains(photo.id)) {
        ref.read(selectedItemsProvider.notifier).removeId(photo.id);
      }
      else {
        ref.read(selectedItemsProvider.notifier).addId(photo.id);
      }
    }
    return;
  }

  ref.read(currentPhotoIdProvider.notifier).set(photo.id);

  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        if (isDesktop()) {
          return DesktopPhotoPage(id: photo.id);
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