import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/album_thumbnail.dart';

import '../providers/albums_provider.dart';

class AlbumPreview extends ConsumerWidget {

  final String id;
  final void Function() onPressed;
  final void Function()? onLongPressed;
  const AlbumPreview({super.key, required this.id, required this.onPressed, this.onLongPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final album = ref.watch(albumsProvider).albums.get(id);

    return GestureDetector(
      onLongPress: onLongPressed,
      onTap: onPressed,
      child: Column(
        children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AlbumThumbnail(album: album),
          )),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(album.title),
          )
        ],
      ),
    );
  }
}