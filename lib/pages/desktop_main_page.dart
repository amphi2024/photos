import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/desktop_nav_menu.dart';
import 'package:photos/models/fragment_index.dart';
import 'package:photos/pages/app_bar/desktop_app_bar_actions.dart';
import 'package:photos/providers/albums_provider.dart';
import 'package:photos/providers/current_photo_id_provider.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/views/photos/photos_view.dart';

import '../utils/update_check.dart';

const double desktopTitleBarHeight = 50;
final contentKey = GlobalKey();

class DesktopMainPage extends ConsumerStatefulWidget {
  const DesktopMainPage({super.key});

  @override
  DesktopMainPageState createState() => DesktopMainPageState();
}

class DesktopMainPageState extends ConsumerState<DesktopMainPage> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  final LayerLink layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    checkForAppUpdate(context);
    checkForServerUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(selectedItemsProvider);
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final currentPhotoId = ref.watch(currentPhotoIdProvider);
    final currentAlbumId = ref.watch(currentAlbumIdProvider);
    final sidebarWidth = ref.watch(sidebarWidthProvider);

    final axisCount = ref.watch(axisCountProvider);
    final currentPhoto = ref.watch(photosProvider).photos.get(currentPhotoId);
    final (idList, placeholder) = switch (fragmentIndex) {
      FragmentIndex.photos => (
      ref.watch(photosProvider).idList,
      AppLocalizations.of(context).get("@no_photos")
      ),
      FragmentIndex.trash => (
      ref.watch(photosProvider).trash,
      AppLocalizations.of(context).get("@no_photos_trash")
      ),
      _ => (
      ref.watch(albumsProvider).albums.get(ref.watch(currentAlbumIdProvider)).photos,
      AppLocalizations.of(context).get("@no_photos_album")
      ),
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          const Positioned(left: 0, top: 0, bottom: 0, child: DesktopNavMenu()),
          Positioned(
              left: sidebarWidth,
              top: MediaQuery.of(context).padding.top,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: desktopTitleBarHeight,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: desktopAppbarActions(
                            currentPhoto: currentPhoto,
                            ref: ref,
                            axisCount: axisCount,
                            context: context,
                            fragmentIndex: fragmentIndex,
                            selectedItems: selectedItems,
                        currentAlbumId: currentAlbumId)),
                  ),
                  Expanded(
                      //TODO: optimize it with custom component instead of nested material app
                      child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: Theme.of(context),
                    darkTheme: Theme.of(context),
                    locale: Localizations.localeOf(context),
                    localizationsDelegates: const [
                      LocalizationDelegate(),
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    key: contentKey,
                    home: Scaffold(
                      body: MouseRegion(
                        onHover: (event) {
                          focusNode.requestFocus();
                        },
                        onExit: (event) {
                          focusNode.unfocus();
                        },
                        child: KeyboardListener(
                            focusNode: focusNode,
                            includeSemantics: false,
                            onKeyEvent: (event) {
                              if (event is KeyUpEvent) {
                                ref.read(selectedItemsProvider.notifier).ctrlPressed = false;
                                ref.read(selectedItemsProvider.notifier).shiftPressed = false;
                                return;
                              }
                              if (event.physicalKey == PhysicalKeyboardKey.metaLeft ||
                                  event.physicalKey == PhysicalKeyboardKey.controlLeft ||
                                  event.physicalKey == PhysicalKeyboardKey.controlRight) {
                                ref.read(selectedItemsProvider.notifier).ctrlPressed = true;
                                ref.read(selectedItemsProvider.notifier).shiftPressed = false;
                                if (ref.watch(selectedItemsProvider) == null) {
                                  ref.read(selectedItemsProvider.notifier).startSelection();
                                }
                              }

                              if (event.physicalKey == PhysicalKeyboardKey.shiftLeft || event.physicalKey == PhysicalKeyboardKey.shiftRight) {
                                ref.read(selectedItemsProvider.notifier).ctrlPressed = false;
                                ref.read(selectedItemsProvider.notifier).shiftPressed = true;
                                if (ref.watch(selectedItemsProvider) == null) {
                                  ref.read(selectedItemsProvider.notifier).startSelection();
                                }
                              }

                              if (ref.read(selectedItemsProvider.notifier).ctrlPressed && event.physicalKey == PhysicalKeyboardKey.keyA) {
                                ref.read(selectedItemsProvider.notifier).addAll(idList);
                              }
                            },
                            child: PhotosView(
                              photos: idList,
                              placeholder: placeholder,
                            )),
                      ),
                    ),
                  ))
                ],
              )),
        ],
      ),
    );
  }
}
