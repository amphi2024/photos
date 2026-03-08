import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/utils/screen_size.dart';

import 'video/video_player.dart';

class PhotoWidget extends ConsumerWidget {
  final BoxFit? fit;
  final String id;
  final bool thumbnail;
  final Widget? thumbnailFallback;
  const PhotoWidget({super.key, required this.id, this.fit, this.thumbnail = false, this.thumbnailFallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(photosProvider).photos.get(id);

    if(thumbnail && (photo.mimeType == "image/webp" || photo.mimeType == "image/gif" || !photo.isImage())) {
        return Image.file(
          File(photo.thumbnailPath),
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return thumbnailFallback ?? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo, size: isDesktopOrTablet(context) ? 80 : 40),
                Text(photo.mimeType.split("/").last.toUpperCase())
              ],
            );
          },
        );
    }

    if(photo.isImage()) {
      return NoFadeImage(
        placeholder: FileImage(File(photo.thumbnailPath)),
        image: FileImage(File(photo.photoPath)),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo, size: isDesktopOrTablet(context) ? 80 : 40),
              Text(photo.mimeType.split("/").last.toUpperCase())
            ],
          );
        },
      );
    }
    else {
      return VideoPlayer(photo: photo);
    }
  }
}

class NoFadeImage extends StatefulWidget {
  final ImageProvider placeholder;
  final ImageProvider image;
  final BoxFit? fit;
  final ImageErrorWidgetBuilder errorBuilder;
  const NoFadeImage({
    required this.placeholder,
    required this.image,
    this.fit = BoxFit.cover,
    super.key, required this.errorBuilder,
  });

  @override
  _NoFadeImageState createState() => _NoFadeImageState();
}

class _NoFadeImageState extends State<NoFadeImage> {
  late ImageProvider currentImage;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    currentImage = widget.placeholder;

    final resolver = widget.image.resolve(const ImageConfiguration());
    resolver.addListener(
      ImageStreamListener(
            (info, _) {
          if (mounted) {
            setState(() {
              currentImage = widget.image;
              isLoaded = true;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: currentImage,
      fit: widget.fit,
      errorBuilder: widget.errorBuilder,
    );
  }
}
