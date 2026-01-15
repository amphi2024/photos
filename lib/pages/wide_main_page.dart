import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/channels/app_method_channel.dart';
import 'package:photos/components/custom_window_button.dart';
import 'package:photos/components/desktop_nav_menu.dart';
import 'package:photos/models/fragment_index.dart';
import 'package:photos/pages/app_bar/app_bar_actions.dart';
import 'package:photos/providers/albums_provider.dart';
import 'package:photos/providers/current_photo_id_provider.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/views/desktop_photo_view.dart';
import 'package:photos/views/photos_view.dart';

import '../utils/update_check.dart';

const double desktopTitleBarHeight = 50;

class WideMainPage extends ConsumerStatefulWidget {
  const WideMainPage({super.key});

  @override
  WideMainPageState createState() => WideMainPageState();
}

class WideMainPageState extends ConsumerState<WideMainPage> {

  @override
  void initState() {
    super.initState();
    checkForAppUpdate(context);
    checkForServerUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme
        .of(context)
        .scaffoldBackgroundColor);
    final selectingItems = ref.watch(selectedItemsProvider) != null;
    final actions = appbarActions(context: context, fragmentIndex: ref.watch(fragmentIndexProvider), ref: ref, selectingItems: selectingItems);
    final currentPhotoId = ref.watch(currentPhotoIdProvider);
    double showingPhotoWidth = MediaQuery
        .of(context)
        .size
        .width - 400;

    final colors = CustomWindowButtonColors(
        iconMouseOver: Theme
            .of(context)
            .textTheme
            .bodyMedium
            ?.color,
        mouseOver: const Color.fromRGBO(125, 125, 125, 0.1),
        iconNormal: Theme
            .of(context)
            .textTheme
            .bodyMedium
            ?.color,
        mouseDown: const Color.fromRGBO(125, 125, 125, 0.1),
        iconMouseDown: Theme
            .of(context)
            .textTheme
            .bodyMedium
            ?.color,
        normal: Theme
            .of(context)
            .scaffoldBackgroundColor
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(toolbarHeight: 0 // This is needed to change the status bar text (icon) color on Android
      ),
      body: Stack(
        children: [
          const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: DesktopNavMenu()
          ),
          Positioned(
              left: 200,
              top: desktopTitleBarHeight + MediaQuery
                  .of(context)
                  .padding
                  .top,
              bottom: 0,
              right: currentPhotoId.isEmpty ? 0 : showingPhotoWidth,
              child: () {
                final fragment = ref.watch(fragmentIndexProvider);
                if (fragment == FragmentIndex.photos) {
                  return PhotosView(photos: ref
                      .watch(photosProvider)
                      .idList, placeholder: AppLocalizations.of(context).get("@no_photos"));
                } else if (fragment == FragmentIndex.trash) {
                  return PhotosView(photos: ref
                      .watch(photosProvider)
                      .trash, placeholder: AppLocalizations.of(context).get("@no_photos_trash"));
                } else {
                  final album = ref
                      .watch(albumsProvider)
                      .albums
                      .get(ref.watch(currentAlbumIdProvider));
                  return PhotosView(photos: album.photos, placeholder: AppLocalizations.of(context).get("@no_photos_album"));
                }
              }()
          ),
          Positioned(
              left: 200,
              top: MediaQuery
                  .of(context)
                  .padding
                  .top,
              right: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (App.isDesktop()) Expanded(child: SizedBox(height: desktopTitleBarHeight, child: MoveWindow())),
                    ...actions,
                    if (Platform.isWindows) ...[
                      Visibility(
                        visible: App.isDesktop(),
                        child: MinimizeCustomWindowButton(colors: colors),
                      ),
                      appWindow.isMaximized
                          ? RestoreCustomWindowButton(
                        colors: colors,
                        onPressed: () {
                          appWindow.restore();
                        },
                      )
                          : MaximizeCustomWindowButton(
                        colors: colors,
                        onPressed: () {
                          appWindow.maximize();
                        },
                      ),
                      CloseCustomWindowButton(
                          colors: CustomWindowButtonColors(
                              mouseOver: const Color(0xFFD32F2F),
                              mouseDown: const Color(0xFFB71C1C),
                              iconNormal: const Color(0xFF805306),
                              iconMouseOver: const Color(0xFFFFFFFF),
                              normal: Theme
                                  .of(context)
                                  .scaffoldBackgroundColor))
                    ],
                  ]
              )),
          Positioned(
            top: desktopTitleBarHeight + MediaQuery
                .of(context)
                .padding
                .top,
            bottom: 0,
            right: 0,
            child: Visibility(
                visible: currentPhotoId.isNotEmpty,
                child: DesktopPhotoView(width: showingPhotoWidth)),
          ),
        ],
      ),
    );
  }
}