import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/tablet_sidebar.dart';
import 'package:photos/pages/app_bar/app_bar_actions.dart';

import '../channels/app_method_channel.dart';
import '../models/fragment_index.dart';
import '../providers/albums_provider.dart';
import '../providers/photos_provider.dart';
import '../providers/providers.dart';
import '../views/photos/photos_view.dart';

class TabletMainPage extends ConsumerStatefulWidget {
  const TabletMainPage({super.key});

  @override
  TabletMainPageState createState() => TabletMainPageState();
}

class TabletMainPageState extends ConsumerState<TabletMainPage> {

  bool sidebarShowing = true;

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme
        .of(context)
        .scaffoldBackgroundColor);
    final selectedItems = ref.watch(selectedItemsProvider);
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final sidebarWidth = ref.watch(sidebarWidthProvider);
    // final currentPhotoId = ref.watch(currentPhotoIdProvider);
    // final currentAlbumId = ref.watch(currentAlbumIdProvider);
    //
    // final axisCount = ref.watch(axisCountProvider);
    // final currentPhoto = ref.watch(photosProvider).photos.get(currentPhotoId);
    final (idList, placeholder) = switch (fragmentIndex) {
      FragmentIndex.photos =>
      (ref
          .watch(photosProvider)
          .idList, AppLocalizations.of(context).get("@no_photos")),
      FragmentIndex.trash =>
      (ref
          .watch(photosProvider)
          .trash, AppLocalizations.of(context).get("@no_photos_trash")),
      _ =>
      (ref
          .watch(albumsProvider)
          .albums
          .get(ref.watch(currentAlbumIdProvider))
          .photos, AppLocalizations.of(context).get("@no_photos_album")),
    };

    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            left: sidebarShowing ? sidebarWidth : 0,
            right: 0,
            bottom: 0,
            top: 0,
            curve: Curves.easeOutQuint,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery
                  .paddingOf(context)
                  .top),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: appbarActions(context: context, fragmentIndex: fragmentIndex, ref: ref, selectedItems: selectedItems),
                  ),
                  Expanded(
                    child: PhotosView(
                      photos: idList,
                      placeholder: placeholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TabletSidebar(
            showing: sidebarShowing,
          ),
          Positioned(left: 0, top: MediaQuery
              .of(context)
              .padding
              .top, child: IconButton(onPressed: () {
                setState(() {
                  sidebarShowing = !sidebarShowing;
                });
          }, icon: const Icon(Icons.view_sidebar_outlined)))
        ],
      ),
    );
  }
}
