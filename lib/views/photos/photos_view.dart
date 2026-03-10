import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_cache.dart';
import 'package:photos/providers/current_photo_id_provider.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/utils/photo_item_press_callback.dart';
import 'package:photos/views/fragment_view_mixin.dart';
import 'package:photos/views/photos/photos_view_grid_item.dart';
import '../../components/nav_menu.dart';
import '../../models/app_storage.dart';
import '../../utils/screen_size.dart';

class PhotosView extends ConsumerStatefulWidget {
  final List photos;
  final String placeholder;
  final BuildContext? context;
  final LayerLink? layerLink;

  const PhotosView({super.key, required this.photos, required this.placeholder, this.context, this.layerLink});

  @override
  ConsumerState<PhotosView> createState() => _PhotosViewState();
}

class _PhotosViewState extends ConsumerState<PhotosView> with FragmentViewMixin {
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    appStorage.refreshDataWithServer(ref);
  }

  @override
  Widget build(BuildContext context) {
    final photoIdList = widget.photos;
    final photos = ref.watch(photosProvider).photos;
    if (photoIdList.isEmpty) {
      return Center(child: Text(widget.placeholder));
    }

    final axisCount = isMobile(context) ? 4 : ref.watch(axisCountProvider);
    final currentPhotoId = ref.watch(currentPhotoIdProvider);
    final selectedItems = ref.watch(selectedItemsProvider);

    return GestureDetector(
      onScaleUpdate: (d) {
        if (d.scale < 0.8 && axisCount < maximumAxisCount) {
          ref.read(axisCountProvider.notifier).set(axisCount + 1);
          return;
        }

        if (d.scale > 1.2 && axisCount > 1) {
          ref.read(axisCountProvider.notifier).set(axisCount - 1);
          return;
        }
      },
      onScaleEnd: (d) {
        appCacheData.axisCount = axisCount;
        appCacheData.save();
      },
      child: RefreshIndicator(
        onRefresh: refresh,
        child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount: photoIdList.length,
            padding: EdgeInsets.only(top: 3, left: 3, right: 3, bottom: MediaQuery.of(context).padding.bottom + navMenuHeight),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: axisCount, mainAxisSpacing: 3, crossAxisSpacing: 3),
            itemBuilder: (context, index) {
              final id = photoIdList[index];
              final photo = photos.get(id);
              return GestureDetector(
                onLongPress: () async {
                  if(Platform.isAndroid || Platform.isIOS) {
                    ref.read(selectedItemsProvider.notifier).startSelection();
                  }
                },
                onTap: () {
                  onPhotoPressed(ref: ref, currentPhotoId: currentPhotoId, photoId: id, context: context, selectedItems: selectedItems);
                },
                child: PhotosViewGridItem(key: ValueKey(id), photo: photo),
              );
            }),
      ),
    );
  }
}