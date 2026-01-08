import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/transfers_button.dart';
import 'package:photos/models/app_cache.dart';
import 'package:photos/pages/app_bar/app_bar_popup_menu.dart';
import 'package:photos/utils/generated_id.dart';
import 'package:photos/utils/photo_utils.dart';
import 'package:amphi/widgets/account/account_button.dart';

import '../channels/app_method_channel.dart';
import '../channels/app_web_channel.dart';
import '../dialogs/edit_album_dialog.dart';
import '../models/album.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';
import '../models/fragment_index.dart';
import '../providers/albums_provider.dart';
import '../providers/providers.dart';
import '../utils/account_utils.dart';
import '../views/settings_view.dart';

class DesktopNavMenu extends ConsumerWidget {
  const DesktopNavMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: 200,
        color: Theme.of(context).navigationDrawerTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Builder(builder: (context) {
                    if (App.isDesktop()) {
                      return SizedBox(height: 50, child: MoveWindow());
                    } else {
                      return const SizedBox(height: 50);
                    }
                  })),
                  AccountButton(onLoggedIn: ({required id, required token, required username}) {
                    onLoggedIn(id: id,
                        token: token,
                        username: username,
                        context: context,
                        ref: ref);
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
                        appMethodChannel.setNavigationBarColor(Theme
                            .of(context)
                            .scaffoldBackgroundColor);
                      }),
                  IconButton(
                      onPressed: () {
                        appStorage.refreshDataWithServer(ref);
                      },
                      icon: const Icon(Icons.refresh))
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MenuText(text: AppLocalizations.of(context).get("@photos")),
                    _MenuItem(
                        icon: Icons.photo_library_outlined,
                        title: AppLocalizations.of(context).get("@library"),
                        onPressed: () {
                          ref.read(fragmentIndexProvider.notifier).set(0);
                        }),
                    _MenuItem(
                        icon: Icons.delete,
                        title: AppLocalizations.of(context).get("@trash"),
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
                            itemCount: ref.read(albumsProvider).idList.length,
                            itemBuilder: (context, index) {
                              final album = ref.watch(albumsProvider).getAlbum(index);
                              return _MenuItem(
                                  icon: Icons.photo_album,
                                  title: album.title,
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
                      )),
                  PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            height: 30,
                            onTap: () {
                              createPhotos(ref);
                            },
                            child: Text(AppLocalizations.of(context).get("@new_photo")),
                          ),
                          PopupMenuItem(
                            height: 30,
                            onTap: () async {
                              final id = await generatedAlbumId();
                              final album = Album(id: id);
                              if(context.mounted) {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EditAlbumDialog(
                                          album: album,
                                        ));
                              }
                            },
                            child: Text(AppLocalizations.of(context).get("@new_album")),
                          ),
                        ];
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 18,
                      )),
                  const TransfersButton(iconSize: 18)
                ],
              )
            ],
          ),
        ));
  }
}

class _MenuText extends StatelessWidget {
  final String text;

  const _MenuText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).dividerColor)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final void Function() onPressed;

  const _MenuItem({required this.icon, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: GestureDetector(
        onTap: () {
          onPressed();
          if(App.isDesktop()) {
            appCacheData.windowHeight = appWindow.size.height;
            appCacheData.windowWidth = appWindow.size.width;
          }
          appCacheData.save();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 8),
              child: Icon(
                icon,
                size: 16,
              ),
            ),
            Expanded(
                child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            )),
          ],
        ),
      ),
    );
  }
}
