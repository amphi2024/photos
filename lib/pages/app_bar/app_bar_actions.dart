import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:photos/components/photo_info.dart';
import 'package:photos/components/transfers_button.dart';
import 'package:photos/dialogs/edit_photo_info_dialog.dart';
import 'package:photos/pages/app_bar/app_bar_popup_menu.dart';
import 'package:photos/providers/current_photo_id_provider.dart';

import '../../components/account_button.dart';
import '../../dialogs/edit_album_dialog.dart';
import '../../dialogs/select_album_dialog.dart';
import '../../models/album.dart';
import '../../models/app_storage.dart';
import '../../models/fragment_index.dart';
import '../../providers/albums_provider.dart';
import '../../providers/photos_provider.dart';
import '../../providers/providers.dart';
import '../../utils/photo_utils.dart';

List<Widget> appbarActions({required BuildContext context, required int fragmentIndex, required WidgetRef ref, required bool selectingItems}) {
  if (selectingItems) {
    if (fragmentIndex == FragmentIndex.photos) {
      return photoSelectionActions(context: context, ref: ref);
    }
    else if (fragmentIndex == FragmentIndex.albums) {
      return albumSelectionActions(context: context, ref: ref);
    }
    else if(fragmentIndex == FragmentIndex.album) {
      return photoSelectionActions(context: context, ref: ref, albumId: ref.read(currentAlbumIdProvider));
    }
    else {
      return trashSelectionActions(context: context, ref: ref);
    }
  }
  final currentPhotoId = ref.watch(currentPhotoIdProvider);

  if(currentPhotoId.isNotEmpty && (App.isWideScreen(context) || App.isDesktop())) {
    final photo = ref.watch(photosProvider).photos.get(currentPhotoId);
    return [
      PopupMenuButton(
          icon: const Icon(Icons.more_horiz),
          itemBuilder: (context) {
            return [
              PopupMenuItem(child: Text(AppLocalizations.of(context).get("@share_photo")), onTap: () {
                sharePhoto(photo);
              }),
              PopupMenuItem(child: Text(AppLocalizations.of(context).get("@photo_details")), onTap: () {
                showDialog(context: context, builder: (context) {
                  return Dialog(
                    child: SizedBox(
                      width: 350,
                      height: 400,
                      child: PhotoInfo(id: currentPhotoId),
                    ),
                  );
                });
              }),
              PopupMenuItem(child: Text(AppLocalizations.of(context).get("@export_photo")), onTap: () {
                exportPhoto(photo);
              }),
              PopupMenuItem(child: Text(AppLocalizations.of(context).get("@edit_photo_info")), onTap: () {
                showDialog(context: context, builder: (context) {
                  return EditPhotoInfoDialog(photo: photo);
                });
              })
            ];
          })
    ];
  }
  return [
    if(!App.isDesktop() && !App.isWideScreen(context)) const TransfersButton(),
    Visibility(
      visible: (fragmentIndex == FragmentIndex.photos || fragmentIndex == FragmentIndex.albums) && !App.isDesktop() && !App.isWideScreen(context),
      child: IconButton(
          onPressed: () {
            if (fragmentIndex == FragmentIndex.photos) {
              createPhotos(ref);
            } else if (fragmentIndex == FragmentIndex.albums) {
              final filename = FilenameUtils.generatedFileName(".album", appStorage.albumsPath);
              final album = Album.fromFilename(filename);
              showDialog(context: context, builder: (context) => EditAlbumDialog(
                album: album,
              ));
            }
          },
          icon: const Icon(Icons.add)),
    ),
    Visibility(
      visible: fragmentIndex == FragmentIndex.settings,
      child: AccountButton(onLoggedIn: () {
        appStorage.refreshDataWithServer(ref);
      }),
    ),
    Visibility(
      visible: fragmentIndex != FragmentIndex.settings,
      child: PopupMenuButton(
          icon: const Icon(Icons.more_horiz),
          itemBuilder: (context) {
           return mainPageAppBarPopupMenuItems(ref: ref, fragmentIndex: fragmentIndex, context: context);
          }),
    ),
  ];
}

List<Widget> photoSelectionActions({required BuildContext context, required WidgetRef ref, String? albumId}) {
  return [
    IconButton(
        onPressed: () {
          ref.read(selectedItemsProvider.notifier).endSelection();
        },
        icon: const Icon(Icons.check_circle_outline)),
    IconButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => const SelectAlbumDialog());
        },
        icon: const Icon(Icons.add)),
    PopupMenuButton(itemBuilder: (context) {
      return [
        PopupMenuItem(child: Text("Download"), onTap: () {
          final selectedPhotos = ref.watch(selectedItemsProvider);
          if(selectedPhotos != null) {
            for(var id in selectedPhotos) {
              // appWebChannel.downloadPhotoFile(photo: ref.watch(photosProvider).photos.get(id), ref: ref);
              print(ref.watch(photosProvider).photos.get(id).photoPath);
            }
          }
        }),
        PopupMenuItem(child: Text("Remove Download"), onTap: () {
          final selectedPhotos = ref.watch(selectedItemsProvider);
          if(selectedPhotos != null) {
            for(var id in selectedPhotos) {
              var file = File(ref.watch(photosProvider).photos.get(id).photoPath);
              file.delete();
            }
          }
        }),
      ];
    }),
    Visibility(
        visible: albumId != null,
        child: IconButton(
        onPressed: () {
          final selectedItems = ref.read(selectedItemsProvider);
          if(albumId == null || selectedItems == null) {
            return;
          }
          showDialog(context: context, builder: (context) {
            return ConfirmationDialog(title: AppLocalizations.of(context).get("@dialog_title_remove_photos_from_album"), onConfirmed: () {
              final album = ref.read(albumsProvider).albums.get(albumId);
              album.photos.removeWhere((element) => selectedItems.contains(element));
              album.save();
              ref.read(albumsProvider.notifier).insertAlbum(album);
            });
          });

        },
        icon: const Icon(Icons.remove))),
    IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ConfirmationDialog(
                    title: AppLocalizations.of(context).get("@dialog_title_move_to_trash_photo"),
                    onConfirmed: () {
                      var list = ref.read(selectedItemsProvider)!;
                      for (var id in list) {
                        var photo = ref.read(photosProvider).photos.get(id);
                        photo.deleted = DateTime.now();
                        photo.save();
                      }
                      ref.read(photosProvider.notifier).movePhotosToTrash(list);
                    });
              });
        },
        icon: const Icon(Icons.delete))
  ];
}

List<Widget> albumSelectionActions({required BuildContext context, required WidgetRef ref}) {
  return [
    IconButton(
        onPressed: () {
          ref.read(selectedItemsProvider.notifier).endSelection();
        },
        icon: const Icon(Icons.check_circle_outline)),
    IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ConfirmationDialog(
                    title: AppLocalizations.of(context).get("@dialog_title_delete_album"),
                    onConfirmed: () {
                      var list = ref.read(selectedItemsProvider)!;
                      for (var id in list) {
                        var albums = ref.read(albumsProvider).albums.get(id);
                        albums.delete();
                      }
                      ref.read(albumsProvider.notifier).deleteAlbums(list);
                    });
              });
        },
        icon: const Icon(Icons.delete))
  ];
}

List<Widget> trashSelectionActions({required BuildContext context, required WidgetRef ref}) {
  return [
    IconButton(
        onPressed: () {
          ref.read(selectedItemsProvider.notifier).endSelection();
        },
        icon: const Icon(Icons.check_circle_outline)),
    IconButton(
        onPressed: () {
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
        },
        icon: const Icon(Icons.restore)),
    IconButton(onPressed: () {
      showDialog(
          context: context,
          builder: (context) {
            return ConfirmationDialog(
                title: AppLocalizations.of(context).get("@dialog_title_delete_selected_photos"),
                onConfirmed: () {
                  var list = ref.read(selectedItemsProvider)!;
                  for (var id in list) {
                    var photo = ref.read(photosProvider).photos.get(id);
                    photo.delete();
                  }
                  ref.read(photosProvider.notifier).deletePhotos(list);
                });
          });
    }, icon: const Icon(Icons.delete))
  ];
}