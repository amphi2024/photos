import 'package:amphi/models/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/album_preview.dart';
import 'package:photos/providers/providers.dart';

import '../providers/albums_provider.dart';

class SelectAlbumDialog extends ConsumerStatefulWidget {
  const SelectAlbumDialog({super.key});

  @override
  ConsumerState<SelectAlbumDialog> createState() => _SelectAlbumDialogState();
}

class _SelectAlbumDialogState extends ConsumerState<SelectAlbumDialog> {
  @override
  Widget build(BuildContext context) {
    int axisCount = (MediaQuery.of(context).size.width / 150).toInt();
    if (axisCount < 1) {
      axisCount = 1;
    }

    final albumIdList = ref.read(albumsProvider).idList;
    final albums = ref.read(albumsProvider).albums;

    double? width;

    if(App.isWideScreen(context)) {
      width = 500;
      axisCount = (MediaQuery.of(context).size.width / 500).toInt();
      if (axisCount < 1) {
        axisCount = 1;
      }
    }

    return Dialog(
      child: SizedBox(
        width: width,
        height: 500,
        child: Stack(
          children: [
            Positioned(
                right: 5,
                top: 5,
                child: IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: const Icon(Icons.cancel_outlined, size: 20,))),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 50,
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: axisCount, mainAxisSpacing: 3, crossAxisSpacing: 3
                ),
                itemCount: albumIdList.length,
                itemBuilder: (context, index) {
                  return AlbumPreview(id: albumIdList[index], onPressed: () {
                    final selectingPhotos = ref.read(selectedItemsProvider);
                    if(selectingPhotos != null) {
                      final album = albums.get(albumIdList[index]);
                      album.photos.addAll(selectingPhotos);
                      album.save();
                      ref.read(albumsProvider.notifier).insertAlbum(album);
                      Navigator.pop(context);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
