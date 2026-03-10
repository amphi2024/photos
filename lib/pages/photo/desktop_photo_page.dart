import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/photo_widget.dart';
import 'package:photos/providers/current_photo_id_provider.dart';
import 'package:photos/providers/photos_provider.dart';

class DesktopPhotoPage extends ConsumerStatefulWidget {
  final String? id;

  const DesktopPhotoPage({super.key, this.id});

  @override
  DesktopPhotoPageState createState() => DesktopPhotoPageState();
}

class DesktopPhotoPageState extends ConsumerState<DesktopPhotoPage> {
  final photoTransformController = TransformationController();

  @override
  Widget build(BuildContext context) {
    final String photoId = widget.id ?? ref.watch(currentPhotoIdProvider);
    final photo = ref.watch(photosProvider).photos.get(photoId);
    ref.listen(currentPhotoIdProvider, (previous, next) {
      if (next.isEmpty) {
        Navigator.pop(context);
      }
    });
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .cardColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 30,
              transformationController: photoTransformController,
              scaleEnabled: true,
              panEnabled: true,
              minScale: 0.5,
              child: Hero(
                  tag: photoId,
                  child: PhotoWidget(photo: photo, thumbnail: false)),
            ),
          )
        ],
      ),
    );
  }
}