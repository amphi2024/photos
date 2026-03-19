import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/window/adaptive_linux_window_buttons.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linux_csd_buttons/linux_csd_buttons.dart';
import 'package:photos/models/app_cache.dart';
import 'package:photos/models/app_settings.dart';
import 'package:photos/models/fragment_index.dart';
import 'package:photos/models/photo.dart';

import '../../components/custom_window_button.dart';
import '../../components/photo_info.dart';
import '../../dialogs/edit_album_dialog.dart';
import '../../dialogs/edit_photo_info_dialog.dart';
import '../../models/album.dart';
import '../../providers/current_photo_id_provider.dart';
import '../../providers/providers.dart';
import '../../utils/delete_photos.dart';
import '../../utils/generated_id.dart';
import '../../utils/handle_offline_access.dart';
import '../../utils/photo_utils.dart';
import '../../utils/remove_photos_from_album.dart';
import '../../utils/screen_size.dart';
import '../../utils/window_control.dart';
import 'app_bar_popup_menu.dart';

List<Widget> desktopAppbarActions(
    {required Photo currentPhoto,
    required WidgetRef ref,
    required int axisCount,
    required BuildContext context,
    required int fragmentIndex,
    required List<String>? selectedItems,
    required String currentAlbumId,
    required CsdTheme? csdTheme}) {
  if (currentPhoto.id.isEmpty) {
    if (selectedItems != null) {
      return [
        IconButton(
            onPressed: () {
              ref.read(selectedItemsProvider.notifier).endSelection();
            },
            icon: const Icon(Icons.check_circle_outline)),
        Expanded(child: MoveWindow()),
        PopupMenuButton(itemBuilder: (context) {
          return [
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("make_available_offline")),
                onTap: () {
                  makePhotosAvailableOffline(ref: ref, selectedItems: selectedItems);
                }),
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("make_online_only")),
                onTap: () {
                  makePhotosOnlineOnly(ref: ref, selectedItems: selectedItems);
                }),
          ];
        }),
        if (fragmentIndex == FragmentIndex.album) ...[
          IconButton(
              onPressed: () {
                removePhotosFromAlbum(ref: ref, selectedItems: selectedItems, albumId: currentAlbumId);
              },
              icon: const Icon(Icons.remove)),
        ],
        if (fragmentIndex == FragmentIndex.trash) ...[
          IconButton(
              onPressed: () {
                restoreSelectedPhotos(context: context, ref: ref);
              },
              icon: const Icon(Icons.restore)),
        ],
        IconButton(
            onPressed: () {
              if (fragmentIndex == FragmentIndex.trash) {
                deleteSelectedPhotosPermanently(context: context, ref: ref);
              } else {
                moveSelectedPhotosToTrash(ref: ref, context: context);
              }
            },
            icon: const Icon(Icons.delete))
      ];
    }
    return [
      const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Icon(Icons.remove, size: 15),
      ),
      SizedBox(
        width: 100,
        child: Slider(
            min: 1,
            max: 15,
            value: 16 - axisCount.toDouble(),
            onChanged: (value) {
              final count = 15 - value.toInt();
              ref.read(axisCountProvider.notifier).set(count);
              appCacheData.axisCount = count;
            }),
      ),
      const Icon(Icons.add, size: 15),
      Expanded(child: MoveWindow()),
      PopupMenuButton(
          tooltip: "",
          itemBuilder: (context) {
            return mainPageAppBarPopupMenuItems(ref: ref, fragmentIndex: fragmentIndex, context: context);
          },
          icon: const Icon(Icons.grid_view_rounded)),
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
      if (Platform.isWindows) ..._windowButtonsWindow(context),
      if (Platform.isLinux && appSettings.prefersCustomTitleBar && !appSettings.windowButtonsOnLeft) AdaptiveLinuxWindowButtons(theme: csdTheme, padding: 4.5, onClose: saveWindowSize, windowButtonsOnLeft: false)
    ];
  }
  return [
    IconButton(
        onPressed: () {
          ref.read(currentPhotoIdProvider.notifier).set("");
        },
        icon: const Icon(Icons.arrow_back_ios_new)),
    const Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Icon(Icons.remove, size: 15),
    ),
    SizedBox(
      width: 100,
      child: Slider(
          min: 1,
          max: maximumAxisCountDouble,
          value: 16 - axisCount.toDouble(),
          onChanged: (value) {
            ref.read(axisCountProvider.notifier).set(15 - value.toInt());
          }),
    ),
    const Icon(Icons.add, size: 15),
    Expanded(child: MoveWindow()),
    IconButton(
        onPressed: () {
          sharePhoto(currentPhoto);
        },
        icon: const Icon(Icons.share)),
    IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: SizedBox(
                    width: 350,
                    height: 400,
                    child: PhotoInfo(id: currentPhoto.id),
                  ),
                );
              });
        },
        icon: const Icon(Icons.info)),
    PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(
                height: 30,
                child: Text(AppLocalizations.of(context).get("@export_photo")),
                onTap: () {
                  exportPhoto(currentPhoto);
                }),
            PopupMenuItem(
                height: 30,
                child: Text(AppLocalizations.of(context).get("@edit_photo_info")),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return EditPhotoInfoDialog(photo: currentPhoto);
                      });
                }),
          ];
        },
        icon: const Icon(Icons.more_horiz),
        tooltip: ""),
    if (Platform.isWindows) ..._windowButtonsWindow(context),
  ];
}

List<Widget> _windowButtonsWindow(BuildContext context) {
  final iconColor = Theme.of(context).textTheme.bodyMedium!.color;
  final colors = CustomWindowButtonColors(
      iconMouseOver: iconColor,
      mouseOver: const Color.fromRGBO(125, 125, 125, 0.1),
      iconNormal: iconColor,
      mouseDown: const Color.fromRGBO(125, 125, 125, 0.1),
      iconMouseDown: iconColor,
      normal: Theme.of(context).scaffoldBackgroundColor);
  return [
    Visibility(
      visible: isDesktop(),
      child: MinimizeCustomWindowButton(colors: colors),
    ),
    appWindow.isMaximized
        ? RestoreCustomWindowButton(
            colors: colors,
            onPressed: () {
              appWindow.restore();
            },
          )
        : MaximizeCustomWindowButton(
            colors: colors,
            onPressed: () {
              appWindow.maximize();
            },
          ),
    CloseCustomWindowButton(
        colors: CustomWindowButtonColors(
            mouseOver: const Color(0xFFD32F2F),
            mouseDown: const Color(0xFFB71C1C),
            iconNormal: iconColor,
            iconMouseOver: const Color(0xFFFFFFFF),
            normal: Theme.of(context).scaffoldBackgroundColor))
  ];
}
