import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/photo.dart';
import 'package:photos/providers/photos_provider.dart';

class PhotoInfo extends ConsumerWidget {
  final String id;

  const PhotoInfo({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.read(photosProvider).photos.get(id);
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
      children: [
        Text(
          photo.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          maxLines: 2,
        ),
        Text(
          photo.date.toLocalizedString(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).dividerColor),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 400), child: Text(photo.note)),
        )
      ],
    );
  }
}
