import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/account/account_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/photo_widget.dart';
import 'package:photos/providers/photos_provider.dart';

import '../channels/app_method_channel.dart';
import '../channels/app_web_channel.dart';
import '../models/app_cache.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';
import '../models/fragment_index.dart';
import '../pages/app_bar/app_bar_popup_menu.dart';
import '../providers/albums_provider.dart';
import '../providers/providers.dart';
import '../utils/account_utils.dart';
import '../views/settings_view.dart';

class TabletSidebar extends ConsumerWidget {
  final bool showing;

  const TabletSidebar({super.key, required this.showing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final currentAlbumId = ref.watch(currentAlbumIdProvider);
    final photos = ref.watch(photosProvider).photos;
    final albumsState = ref.watch(albumsProvider);
    final albumIdList = albumsState.idList;
    final sidebarWidth = ref.watch(sidebarWidthProvider);

    return AnimatedPositioned(
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 500),
      left: showing ? 0 : -sidebarWidth - 10,
      top: 0,
      bottom: 0,
      child: Container(
        width: sidebarWidth,
        color: Theme.of(context).navigationDrawerTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AccountButton(
                            onLoggedIn: ({required id, required token, required username}) {
                              onLoggedIn(id: id, token: token, username: username, context: context, ref: ref);
                            },
                            iconSize: 30,
                            profileIconSize: 15,
                            wideScreenIconSize: 25,
                            wideScreenProfileIconSize: 15,
                            appWebChannel: appWebChannel,
                            appStorage: appStorage,
                            appCacheData: appCacheData,
                            onUserRemoved: () {
                              onUserRemoved(ref);
                            },
                            onUserAdded: () {
                              onUserAdded(ref);
                            },
                            onUsernameChanged: () {
                              onUsernameChanged(ref);
                            },
                            onSelectedUserChanged: (user) {
                              onSelectedUserChanged(user, ref);
                            },
                            setAndroidNavigationBarColor: () {
                              appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
                            })
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MenuText(text: AppLocalizations.of(context).get("@photos")),
                          _MenuItem(
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 16,
                              ),
                              title: AppLocalizations.of(context).get("@library"),
                              focused: fragmentIndex == FragmentIndex.photos,
                              onPressed: () {
                                ref.read(fragmentIndexProvider.notifier).set(0);
                              }),
                          _MenuItem(
                              icon: const Icon(
                                Icons.delete,
                                size: 16,
                              ),
                              title: AppLocalizations.of(context).get("@trash"),
                              focused: fragmentIndex == FragmentIndex.trash,
                              onPressed: () {
                                ref.read(fragmentIndexProvider.notifier).set(2);
                              }),
                          Row(
                            children: [
                              Expanded(child: _MenuText(text: AppLocalizations.of(context).get("@albums"))),
                              PopupMenuButton(
                                padding: EdgeInsets.zero,
                                itemBuilder: (context) {
                                  return albumsPopupMenuItems(ref: ref, context: context);
                                },
                                icon: const Icon(Icons.more_horiz),
                                iconSize: 14,
                              )
                            ],
                          ),
                          Expanded(
                              child: ListView.builder(
                                  itemCount: albumIdList.length,
                                  itemBuilder: (context, index) {
                                    final album = albumsState.getAlbum(index);
                                    final coverPhoto = album.getCoverPhoto(photos);
                                    return _MenuItem(
                                        icon: coverPhoto != null
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: PhotoWidget(
                                                    photo: coverPhoto,
                                                    thumbnail: true,
                                                    thumbnailFallback: const Icon(
                                                      Icons.photo_album,
                                                      size: 16,
                                                    )),
                                              )
                                            : const Icon(
                                                Icons.photo_album,
                                                size: 16,
                                              ),
                                        title: album.title,
                                        focused: currentAlbumId == album.id && fragmentIndex == FragmentIndex.album,
                                        onPressed: () {
                                          ref.read(currentAlbumIdProvider.notifier).set(album.id);
                                          if (ref.watch(fragmentIndexProvider) != FragmentIndex.album) {
                                            ref.read(fragmentIndexProvider.notifier).set(FragmentIndex.album);
                                          }
                                        });
                                  }))
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                        child: SizedBox(
                                          width: 450,
                                          height: 500,
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                    onPressed: () {
                                                      appSettings.save();
                                                      Navigator.pop(context);
                                                    },
                                                    icon: const Icon(Icons.cancel_outlined)),
                                              ),
                                              const Expanded(child: SettingsView()),
                                            ],
                                          ),
                                        ),
                                      )).then((value) {
                                appSettings.save();
                              });
                            },
                            icon: const Icon(
                              Icons.settings,
                              size: 18,
                            ))
                      ],
                    )
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: () {
                  ref.read(sidebarWidthProvider.notifier).set(200);
                  appCacheData.sidebarWidth = 200;
                  appCacheData.save();
                },
                onHorizontalDragUpdate: (d) {
                  ref.read(sidebarWidthProvider.notifier).set(sidebarWidth + d.delta.dx);
                },
                onHorizontalDragEnd: (d) {
                  appCacheData.sidebarWidth = sidebarWidth;
                  appCacheData.save();
                },
                child: const SizedBox(
                  width: 5,
                  child: VerticalDivider(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuText extends StatelessWidget {
  final String text;

  const _MenuText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).disabledColor)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final bool focused;
  final void Function() onPressed;

  const _MenuItem({required this.icon, required this.title, required this.onPressed, required this.focused});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Material(
        color: focused ? Theme.of(context).dividerColor.withAlpha(50) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          mouseCursor: SystemMouseCursors.basic,
          borderRadius: BorderRadius.circular(8),
          highlightColor: const Color.fromARGB(25, 125, 125, 125),
          splashColor: const Color.fromARGB(25, 125, 125, 125),
          onTap: () {
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 13, right: 8),
                  child: icon,
                ),
                Expanded(
                    child: Text(
                  title,
                  style: const TextStyle(fontSize: 14),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
