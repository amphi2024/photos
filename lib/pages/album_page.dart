import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/albums_provider.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/views/photos_view.dart';

import '../channels/app_method_channel.dart';
import '../providers/providers.dart';
import 'app_bar/app_bar_actions.dart';
import 'app_bar/app_bar_popup_menu.dart';

class AlbumPage extends ConsumerWidget {

  final String id;

  const AlbumPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    appMethodChannel.setNavigationBarColor(Theme
        .of(context)
        .scaffoldBackgroundColor);
    final selectingPhotos = ref.watch(selectedItemsProvider) != null;
    final album = ref.watch(albumsProvider).albums.get(id);
    int axisCount = (MediaQuery
        .of(context)
        .size
        .width / 80).toInt();
    if (axisCount < 0) {
      axisCount = 1;
    }

    return PopScope(
      canPop: !selectingPhotos,
      onPopInvokedWithResult: (didPop, result) {
        if (selectingPhotos) {
          ref.read(selectedItemsProvider.notifier).endSelection();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 55,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: Visibility(
            visible: !selectingPhotos,
            child: IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: const Icon(Icons.arrow_back_ios_new)),
          ),
          title: Visibility(
              visible: !selectingPhotos,
              child: Text(album.title)
          ),
          actions: selectingPhotos ? photoSelectionActions(context: context, ref: ref, albumId: id) : [
            PopupMenuButton(itemBuilder: (context) {
              return albumPageAppBarPopupMenuItems(
                id: id,
                ref: ref,
                context: context
              );
            }, icon: const Icon(Icons.more_horiz))
          ],
        ),
        body: PhotosView(photos: album.getVisiblePhotos(ref.watch(photosProvider).photos), placeholder: AppLocalizations.of(context).get("@no_photos_album")),
      ),
    );
  }
}