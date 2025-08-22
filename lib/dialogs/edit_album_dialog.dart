import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/album.dart';

import '../providers/albums_provider.dart';

class EditAlbumDialog extends ConsumerStatefulWidget {

  final Album album;
  const EditAlbumDialog({super.key, required this.album});

  @override
  ConsumerState<EditAlbumDialog> createState() => _EditAlbumDialogState();
}

class _EditAlbumDialogState extends ConsumerState<EditAlbumDialog> {

  late final controller = TextEditingController(text: widget.album.title);

  @override
  Widget build(BuildContext context) {

    double? width;

    if(App.isWideScreen(context)) {
      width = 300;
    }

    return Dialog(
      child: SizedBox(
        width: width,
        height: 125,
        child: Stack(
          children: [
            Positioned(
                left: 15,
                right: 15,
                top: 8,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).get("@hint_title")
                  ),
                )
            ),
            Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        widget.album.title = controller.text;
                        widget.album.created = DateTime.now();
                        widget.album.modified = DateTime.now();
                        widget.album.save();
                        ref.read(albumsProvider.notifier).insertAlbum(widget.album);
                        Navigator.pop(context);
                      },
                    )
                  ],))
          ],
        ),
      ),
    );
  }
}
