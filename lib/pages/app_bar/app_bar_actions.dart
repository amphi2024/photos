import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/account/account_button.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/pages/app_bar/app_bar_popup_menu.dart';
import 'package:photos/utils/generated_id.dart';

import '../../channels/app_method_channel.dart';
import '../../channels/app_web_channel.dart';
import '../../dialogs/edit_album_dialog.dart';
import '../../dialogs/select_album_dialog.dart';
import '../../models/album.dart';
import '../../models/app_cache.dart';
import '../../models/app_storage.dart';
import '../../models/fragment_index.dart';
import '../../providers/albums_provider.dart';
import '../../providers/providers.dart';
import '../../utils/account_utils.dart';
import '../../utils/delete_photos.dart';
import '../../utils/handle_offline_access.dart';
import '../../utils/photo_utils.dart';
import '../../utils/remove_photos_from_album.dart';

List<Widget> appbarActions({required BuildContext context, required int fragmentIndex, required WidgetRef ref, required List<String>? selectedItems}) {
  if (selectedItems != null) {
    if (fragmentIndex == FragmentIndex.photos) {
      return photoSelectionActions(context: context, ref: ref, selectedItems: selectedItems);
    } else if (fragmentIndex == FragmentIndex.albums) {
      return albumSelectionActions(context: context, ref: ref);
    } else if (fragmentIndex == FragmentIndex.album) {
      return photoSelectionActions(context: context, ref: ref, albumId: ref.read(currentAlbumIdProvider), selectedItems: selectedItems);
    } else {
      return trashSelectionActions(context: context, ref: ref);
    }
  }

  return [
    PopupMenuButton(
        tooltip: "",
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              height: 30,
              onTap: () {
                createPhotos(ref);
              },
              child: Text(AppLocalizations.of(context).get("@new_photo")),
            ),
            PopupMenuItem(
              height: 30,
              onTap: () async {
                final id = await generatedAlbumId();
                final album = Album(id: id);
                if (context.mounted) {
                  showDialog(
                      context: context,
                      builder: (context) => EditAlbumDialog(
                        album: album,
                      ));
                }
              },
              child: Text(AppLocalizations.of(context).get("@new_album")),
            ),
          ];
        },
        icon: const Icon(Icons.add_circle_outline)),
    Visibility(
      visible: fragmentIndex == FragmentIndex.settings,
      child: AccountButton(
          onLoggedIn: ({required id, required token, required username}) {
            onLoggedIn(id: id, token: token, username: username, context: context, ref: ref);
          },
          iconSize: 30,
          profileIconSize: 15,
          wideScreenIconSize: 25,
          wideScreenProfileIconSize: 15,
          appWebChannel: appWebChannel,
          appStorage: appStorage,
          appCacheData: appCacheData,
          onUserRemoved: () {
            onUserRemoved(ref);
          },
          onUserAdded: () {
            onUserAdded(ref);
          },
          onUsernameChanged: () {
            onUsernameChanged(ref);
          },
          onSelectedUserChanged: (user) {
            onSelectedUserChanged(user, ref);
          },
          setAndroidNavigationBarColor: () {
            appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
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

List<Widget> photoSelectionActions({required BuildContext context, required WidgetRef ref, String? albumId, required List<String>? selectedItems}) {
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
        PopupMenuItem(
            child: Text(AppLocalizations.of(context).get("make_available_offline")),
            onTap: () {
              makePhotosAvailableOffline(ref);
            }),
        PopupMenuItem(
            child: Text(AppLocalizations.of(context).get("make_online_only")),
            onTap: () {
              if(selectedItems != null) {
                makePhotosOnlineOnly(ref: ref, selectedItems: selectedItems);
              }
            }),
      ];
    }),
    Visibility(
        visible: albumId != null,
        child: IconButton(
            onPressed: () {
              final selectedItems = ref.read(selectedItemsProvider);
              if (albumId == null || selectedItems == null) {
                return;
              }
              showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationDialog(
                        title: AppLocalizations.of(context).get("@dialog_title_remove_photos_from_album"),
                        onConfirmed: () {
                          removePhotosFromAlbum(ref: ref, selectedItems: selectedItems, albumId: albumId);
                        });
                  });
            },
            icon: const Icon(Icons.remove))),
    IconButton(
        onPressed: () {
          moveSelectedPhotosToTrash(ref: ref, context: context);
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
          restoreSelectedPhotos(context: context, ref: ref);
        },
        icon: const Icon(Icons.restore)),
    IconButton(
        onPressed: () {
          deleteSelectedPhotosPermanently(context: context, ref: ref);
        },
        icon: const Icon(Icons.delete))
  ];
}
