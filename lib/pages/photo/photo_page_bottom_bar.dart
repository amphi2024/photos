import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/dialogs/select_album_dialog.dart';
import 'package:photos/pages/photo/photo_page.dart';
import 'package:photos/providers/current_photo_id_provider.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/utils/photo_utils.dart';

import '../../components/bottom_sheet_drag_handle.dart';
import '../../components/photo_info.dart';

const double _iconSize = 25;

class PhotoPageBottomBar extends ConsumerWidget {
  
  const PhotoPageBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(photosProvider).photos.get(ref.watch(currentPhotoIdProvider));

    return Container(
      height: photoPageTitleBarHeight + MediaQuery.of(context).padding.bottom,
      color: Theme
          .of(context)
          .appBarTheme
          .backgroundColor,
      child:  Align(
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {
              sharePhoto(photo); 
            }, icon: const Icon(
              Icons.share,
              size: _iconSize,
            )),
            IconButton(onPressed: () {
              showModalBottomSheet(context: context, builder: (context) {
                double height = 300;
                if(MediaQuery.of(context).size.height < height) {
                  height = MediaQuery.of(context).size.height - 50;
                }
                return Container(
                  height: height,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                          left: 0,
                          right: 0,
                          top: 5,
                          child: BottomSheetDragHandle()
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 30,
                          child: PhotoInfo(id: ref.watch(currentPhotoIdProvider))
                      )
                    ],
                  ),
                );
              });
            }, icon: const Icon(
              Icons.info,
              size: _iconSize,
            )),
            IconButton(onPressed: () {
              ref.read(selectedItemsProvider.notifier).startSelection();
              ref.read(selectedItemsProvider.notifier).addId(photo.id);
              showDialog(context: context, builder: (context) {
                return const SelectAlbumDialog();
              }).then((value) {
               ref.read(selectedItemsProvider.notifier).endSelection();
              });
            }, icon: const Icon(
              Icons.add,
              size: _iconSize,
            )),
            IconButton(
                onPressed: () {
                  showDialog(context: context, builder: (context) {
                    return ConfirmationDialog(title: AppLocalizations.of(context).get("@dialog_title_move_to_trash_photo"), onConfirmed: () {
                      photo.deleted = DateTime.now();
                      photo.save();
                      ref.read(photosProvider.notifier).movePhotosToTrash([photo.id]);
                      Navigator.pop(context);
                    });
                  });
                }, icon: const Icon(
              Icons.delete,
              size: _iconSize,
            )),
          ],
        ),
      ),
    );
  }
}
