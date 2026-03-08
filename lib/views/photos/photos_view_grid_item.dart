import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/providers/transfers_provider.dart';
import 'package:photos/utils/screen_size.dart';

import '../../components/photo_widget.dart';

class PhotosViewGridItem extends ConsumerWidget {

  final String id;
  const PhotosViewGridItem({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = ref.watch(selectedItemsProvider);
    final photo = ref.watch(photosProvider).photos.get(id);
    final transfer = ref.watch(transfersProvider)[id];

    if(isDesktop()) {
      return Draggable<List<String>>(
        dragAnchorStrategy: pointerDragAnchorStrategy,
        data: selectedItems ?? [id],
        feedback: SizedBox(
          width: 100,
            height: 100,
            child: PhotoWidget(key: Key(selectedItems?.firstOrNull ?? id), id: selectedItems?.firstOrNull ?? id, fit: BoxFit.cover, thumbnail: true)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                  tag: id,
                  child: PhotoWidget(key: Key(id), id: id, fit: BoxFit.cover, thumbnail: true)),
            ),
            Visibility(
              visible: !photo.availableOnOffline && transfer == null,
              child: Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(onPressed: () {
                    appWebChannel.downloadPhotoFile(photo: photo, ref: ref);
                  }, icon: const Icon(Icons.arrow_downward, color: Colors.white))),
              // TODO: Adapt icon color to image
            ),
            if(transfer != null) ... [
              Positioned(
                right: 5,
                bottom: 5,
                child: CircularPercentIndicator(
                    radius: 10,
                    lineWidth: 5,
                    animation: false,
                    percent: (transfer.received / transfer.total).toDouble(),
                    progressColor: Theme.of(context).highlightColor),
              )
            ],
            Visibility(
                visible: selectedItems?.contains(id) == true,
                child: Container(decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).highlightColor, width: 3)
                )))
          ],
        )
      );
    }

    return Hero(
        tag: id,
        child: Stack(
          children: [
            Positioned.fill(child: PhotoWidget(key: Key(id), id: id, fit: BoxFit.cover, thumbnail: true)),
            Positioned(
                left: 0,
                top: 0,
                child: AnimatedOpacity(
                  opacity: selectedItems != null ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuint,
                  child: IgnorePointer(
                    ignoring: selectedItems == null,
                    child: Material(
                      color: Colors.transparent,
                      child: Checkbox(
                          value: selectedItems?.contains(id) ?? false,
                          onChanged: (value) {
                            if (value == true) {
                              ref.read(selectedItemsProvider.notifier).addId(id);
                            } else {
                              ref.read(selectedItemsProvider.notifier).removeId(id);
                            }
                          }),
                    ),
                  ),
                )),
            if(transfer != null) ... [
              Positioned(
                right: 5,
                bottom: 5,
                child: CircularPercentIndicator(
                    radius: 10,
                    lineWidth: 5,
                    animation: false,
                    percent: (transfer.received / transfer.total).toDouble(),
                    progressColor: Theme.of(context).highlightColor),
              )
            ]
          ],
        ));
  }
}
