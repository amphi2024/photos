import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:photos/models/photo.dart';
import 'package:photos/utils/screen_size.dart';

import 'video/video_player.dart';

class PhotoWidget extends StatelessWidget {
  final BoxFit? fit;
  final Photo photo;
  final bool thumbnail;
  final Widget? thumbnailFallback;
  final Uint8List? bytes;

  const PhotoWidget({super.key, required this.photo, this.fit, this.thumbnail = false, this.thumbnailFallback, this.bytes});

  @override
  Widget build(BuildContext context) {
    if (thumbnail) {
      return Image.file(
        File(photo.thumbnailPath),
        fit: fit,
        cacheWidth: 300,
        errorBuilder: (context, error, stackTrace) {
          return thumbnailFallback ??
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.photo, size: isDesktopOrTablet(context) ? 80 : 40), Text(photo.mimeType.split("/").last.toUpperCase())],
              );
        },
      );
    }

    if (photo.isImage()) {
      return NoFadeImage(
          fit: fit,
          placeholder: FileImage(File(photo.thumbnailPath)),
          image: photo.availableOnOffline
              ? FileImage(File(photo.photoPath))
              : NetworkImage("${appWebChannel.serverAddress}/photos/${photo.id}", headers: {"Authorization": appWebChannel.token}),
          errorBuilder: (context, error, stackTrace) {
            return Image.network("${appWebChannel.serverAddress}/photos/${photo.id}", fit: fit, headers: {"Authorization": appWebChannel.token});
          });
    } else {
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
    super.key,
    required this.errorBuilder,
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
