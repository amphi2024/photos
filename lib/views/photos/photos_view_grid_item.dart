import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:photos/providers/current_photo_id_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/providers/transfers_provider.dart';
import 'package:photos/utils/screen_size.dart';

import '../../components/photo_widget.dart';
import '../../models/photo.dart';
import '../../pages/photo/desktop_photo_page.dart';
import '../../pages/photo/photo_page.dart';

class PhotosViewGridItem extends ConsumerWidget {
  final Photo photo;
  const PhotosViewGridItem({super.key, required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = photo.id;
    final currentPhotoId = ref.watch(currentPhotoIdProvider);
    final isSelected = ref.watch(selectedItemsProvider.select((list) => list?.contains(id) ?? false));
    final transfer = ref.watch(transfersProvider.select((map) => map[id]));
    final isSelectionMode = ref.watch(selectedItemsProvider.select((list) => list != null));
    ref.listen(currentPhotoIdProvider, (previous, next) {
      if(next == photo.id) {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              if (isDesktop()) {
                return DesktopPhotoPage(id: id);
              }
              return const PhotoPage();
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });

    if (isDesktop()) {
      return Draggable<List<String>>(
          dragAnchorStrategy: pointerDragAnchorStrategy,
          data: isSelected ? ref.read(selectedItemsProvider) ?? [id] : [id],
          feedback: SizedBox(
              width: 100,
              height: 100,
              child: PhotoWidget(key: Key(photo.id), photo: photo, fit: BoxFit.cover, thumbnail: true)),
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(tag: id, child: PhotoWidget(key: ValueKey(id), photo: photo, fit: BoxFit.cover, thumbnail: currentPhotoId != id)),
              ),
              Visibility(
                visible: !photo.availableOnOffline && transfer == null,
                child: Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                        onPressed: () {
                          appWebChannel.downloadPhotoFile(photo: photo, ref: ref);
                        },
                        icon: const Icon(Icons.arrow_downward, color: Colors.white))),
                // TODO: Adapt icon color to image
              ),
              if (transfer != null) ...[
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
                  visible: isSelected,
                  child: Container(decoration: BoxDecoration(border: Border.all(color: Theme.of(context).highlightColor, width: 3))))
            ],
          ));
    }

    return Hero(
        tag: id,
        child: Stack(
          children: [
            Positioned.fill(child: PhotoWidget(key: ValueKey(id), photo: photo, fit: BoxFit.cover, thumbnail: currentPhotoId != id)),
            Positioned(
                left: 0,
                top: 0,
                child: AnimatedOpacity(
                  opacity: isSelectionMode ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuint,
                  child: IgnorePointer(
                    ignoring: isSelectionMode,
                    child: Material(
                      color: Colors.transparent,
                      child: Checkbox(
                          value: isSelected,
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
            if (transfer != null) ...[
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