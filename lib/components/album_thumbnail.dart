import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/album.dart';

import '../providers/photos_provider.dart';
import 'photo_widget.dart';

const double _radius = 15;

class AlbumThumbnail extends ConsumerWidget {
  
  final Album album;
  final double iconSize;
  const AlbumThumbnail({super.key, required this.album, this.iconSize = 60});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider).photos;
    final coverPhoto = album.getCoverPhoto(photos);

    if(coverPhoto != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: SizedBox.expand(child: PhotoWidget(photo: coverPhoto, fit: BoxFit.cover, thumbnail: true)));
    }
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            color: Theme.of(context).cardColor
        ),
        child: Center(
          child: Icon(
            Icons.photo_album,
            size: iconSize,
          ),
        ),
      );
    }
}
