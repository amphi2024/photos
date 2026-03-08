import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/photos_provider.dart';
import '../providers/providers.dart';

void moveSelectedPhotosToTrash({required BuildContext context, required WidgetRef ref}) {
  showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
            title: AppLocalizations.of(context).get("@dialog_title_move_to_trash_photo"),
            onConfirmed: () {
              final list = ref.read(selectedItemsProvider)!;
              for (final id in list) {
                final photo = ref.read(photosProvider).photos.get(id);
                photo.deleted = DateTime.now();
                photo.save();
              }
              ref.read(photosProvider.notifier).movePhotosToTrash(list);
            });
      });
}

void deleteSelectedPhotosPermanently({required BuildContext context, required WidgetRef ref}) {
  showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
            title: AppLocalizations.of(context).get("@dialog_title_delete_selected_photos"),
            onConfirmed: () {
              final list = ref.read(selectedItemsProvider)!;
              for (final id in list) {
                final photo = ref.read(photosProvider).photos.get(id);
                photo.delete();
              }
              ref.read(photosProvider.notifier).deletePhotos(list);
            });
      });
}

void restoreSelectedPhotos({required BuildContext context, required WidgetRef ref}) {
  showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
          title: AppLocalizations.of(context).get("@dialog_title_restore_selected_photos"),
          onConfirmed: () {
            var list = ref.read(selectedItemsProvider)!;
            for (var id in list) {
              var photo = ref.read(photosProvider).photos.get(id);
              photo.deleted = null;
              photo.save();
            }
            ref.read(photosProvider.notifier).restorePhotos(list);
          }));
}