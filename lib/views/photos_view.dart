import 'package:amphi/models/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/photo_widget.dart';
import 'package:photos/providers/current_photo_id_provider.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/views/fragment_view_mixin.dart';
import '../components/nav_menu.dart';
import '../models/app_storage.dart';
import '../pages/photo/photo_page.dart';

class PhotosView extends ConsumerStatefulWidget {

  final List photos;
  final bool itemClickEnabled;
  final String placeholder;
  const PhotosView({super.key, required this.photos, this.itemClickEnabled = true, required this.placeholder});

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
    if(photoIdList.isEmpty) {
      return Center(child: Text(widget.placeholder));
    }
    var itemSize = 80;
    if(App.isWideScreen(context) || App.isDesktop()) {
      itemSize = 175;
    }

    int axisCount = (MediaQuery.of(context).size.width / itemSize).toInt();
    if(ref.watch(currentPhotoIdProvider).isNotEmpty && (App.isWideScreen(context) || App.isDesktop())) {
      axisCount = (axisCount / 4).toInt();
    }
    if (axisCount < 1) {
      axisCount = 1;
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          itemCount: photoIdList.length,
          // itemCount: 70,
          padding: EdgeInsets.only(
            top: 3,
              left: 3,
              right: 3,
              bottom: MediaQuery.of(context).padding.bottom + navMenuHeight
              ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: axisCount,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3),
          itemBuilder: (context, index) {
            final id = photoIdList[index];
            photos.get(id);
            return GestureDetector(
              onLongPress: () async {
                ref.read(selectedItemsProvider.notifier).startSelection();
              },
              onTap: () {
                if(ref.read(selectedItemsProvider) != null || !widget.itemClickEnabled) {
                  return;
                }
                if(ref.watch(currentPhotoIdProvider) == id) {
                  ref.read(currentPhotoIdProvider.notifier).set("");
                }
                else {
                  ref.read(currentPhotoIdProvider.notifier).set(id);
                }

                if(!App.isWideScreen(context) && !App.isDesktop()) {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) => const PhotoPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                }
              },
              child: Hero(
                tag: id,
                child: Stack(
                  children: [
                    Positioned.fill(child: PhotoWidget(key: Key(id), id: id, fit: BoxFit.cover, thumbnail: true)),
                    Positioned(
                      left: 0,
                        top: 0,
                        child:
                        AnimatedOpacity(
                          opacity: ref.watch(selectedItemsProvider) != null ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutQuint,
                          child: IgnorePointer(
                            ignoring: ref.watch(selectedItemsProvider) == null,
                            child: Material(
                              color: Colors.transparent,
                              child: Checkbox(
                                  value: ref.watch(selectedItemsProvider)?.contains(id) ?? false, onChanged: (value) {
                                if(value == true) {
                                  ref.read(selectedItemsProvider.notifier).addId(id);
                                }
                                else {
                                  ref.read(selectedItemsProvider.notifier).removeId(id);
                                }
                              }),
                            ),
                          ),
                        ))
                  ],
                )
              ),
            );
          }),
    );
  }
}