import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/photo_widget.dart';
import 'package:photos/providers/current_photo_id_provider.dart';

class DesktopPhotoView extends ConsumerWidget {

  final double width;

  const DesktopPhotoView({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final id = ref.watch(currentPhotoIdProvider);
    return SizedBox(
      width: width,
      child: InteractiveViewer(
      minScale: 1,
      maxScale: 30,
      child: PhotoWidget(id: id, key: Key(id))),
    );
  }
}
