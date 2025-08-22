import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photos/dialogs/edit_photo_info_dialog.dart';
import 'package:photos/pages/photo/photo_page.dart';
import 'package:photos/utils/photo_utils.dart';

import '../../providers/current_photo_id_provider.dart';
import '../../providers/photos_provider.dart';

class PhotoPageTitleBar extends ConsumerWidget {

  const PhotoPageTitleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(photosProvider).photos.get(ref.watch(currentPhotoIdProvider));

    return Container(
      height: photoPageTitleBarHeight + MediaQuery
          .of(context)
          .padding
          .top,
      color: Theme
          .of(context)
          .appBarTheme
          .backgroundColor,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 25,
            )),
            SizedBox(
              height: photoPageTitleBarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat.MMMd().format(photo.date),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                  Text(
                    DateFormat.jm().format(photo.date),
                    style: const TextStyle(
                        fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(icon: const Icon(
              Icons.more_horiz,
              size: 25,
            ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(child: Text(AppLocalizations.of(context).get("@export_photo")), onTap: () {
                    exportPhoto(photo);
                  }),
                  PopupMenuItem(child: Text(AppLocalizations.of(context).get("@edit_photo_info")), onTap: () {
                    showDialog(context: context, builder: (context) {
                      return EditPhotoInfoDialog(photo: photo);
                    });
                  }),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
