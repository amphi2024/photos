import 'package:amphi/models/account_info_bottom_sheet.dart';
import 'package:amphi/models/app.dart';
import 'package:amphi/models/user.dart';
import 'package:amphi/widgets/account/account_info.dart';
import 'package:flutter/material.dart';
import 'package:amphi/widgets/account/profile_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_cache.dart';
import 'package:photos/models/app_state.dart';
import 'package:photos/models/app_storage.dart';
import 'package:photos/components/bottom_sheet_drag_handle.dart';

import '../../../channels/app_method_channel.dart';
import '../../../channels/app_web_channel.dart';
import '../../../models/app_settings.dart';
import '../providers/albums_provider.dart';
import '../providers/photos_provider.dart';

class AccountButton extends ConsumerStatefulWidget {

  final void Function() onLoggedIn;
  const AccountButton({super.key, required this.onLoggedIn});

  @override
  AccountButtonState createState() => AccountButtonState();
}

class AccountButtonState extends ConsumerState<AccountButton> {


  void onUserRemoved() {
    appSettings.data = {};
    appWebChannel.disconnectWebSocket();
    appStorage.initPaths();
    appSettings.getData();
    appWebChannel.connectWebSocket();
    ref.read(photosProvider.notifier).clear();
    ref.read(photosProvider.notifier).init();
    ref.read(albumsProvider.notifier).init(ref.read(photosProvider).photos);
    setState(() {

    });
    appState.onSettingsChanged(() {

    });
    appState.onServerAddressChanged();
  }

  void onUserAdded() {
    appSettings.data = {};
    appWebChannel.disconnectWebSocket();
    appStorage.initPaths();
    appSettings.getData();
    ref.read(photosProvider.notifier).clear();
    ref.read(photosProvider.notifier).init();
    ref.read(albumsProvider.notifier).init(ref.read(photosProvider).photos);
    setState(() {

    });
    appState.onSettingsChanged(() {

    });
    appState.onServerAddressChanged();
  }

  void onUsernameChanged() {

  }

  void onSelectedUserChanged(User user) {
    appSettings.data = {};
    appWebChannel.disconnectWebSocket();
    appStorage.initPaths();
    appSettings.getData();
    ref.read(photosProvider.notifier).clear();
    ref.read(photosProvider.notifier).init();
    ref.read(albumsProvider.notifier).init(ref.read(photosProvider).photos);
    appStorage.syncDataFromEvents(ref);
    setState(() {

    });
    appState.onSettingsChanged(() {

    });
    appState.onServerAddressChanged();
  }

  void onLoggedIn({required String id, required String token, required String username, required BuildContext context}) async {
    appStorage.selectedUser.id = id;
    Navigator.popUntil(
      context,
          (Route<dynamic> route) => route.isFirst,
    );
    appStorage.selectedUser.name = username;
    appStorage.selectedUser.token = token;
    await appStorage.saveSelectedUserInformation();
    widget.onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 20;
    double profileIconSize = 15;
    if (App.isWideScreen(context)) {
      iconSize = 20;
      profileIconSize = 15;
    }
    return IconButton(
        icon: ProfileImage(size: iconSize, fontSize: profileIconSize, user: appStorage.selectedUser, token: appWebChannel.token),
        onPressed: () {
          if (App.isWideScreen(context)) {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: SizedBox(
                      width: 250,
                      height: 500,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                icon: const Icon(Icons.cancel_outlined),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ),
                          Expanded(
                              child: AccountInfo(
                                appStorage: appStorage,
                                appWebChannel: appWebChannel,
                                appCacheData: appCacheData,
                                onUserRemoved: onUserRemoved,
                                onUserAdded: onUserAdded,
                                onLoggedIn: ({required id, required token, required username}) {
                                  onLoggedIn(id: id, token: token, username: username, context: context);
                                },
                                onUsernameChanged: onUsernameChanged,
                                onSelectedUserChanged: onSelectedUserChanged,
                              ))
                        ],
                      ),
                    ),
                  );
                });
          } else {
            appMethodChannel.setNavigationBarColor(Theme
                .of(context)
                .scaffoldBackgroundColor);
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return AccountInfoBottomSheet(
                    appWebChannel: appWebChannel,
                    appStorage: appStorage,
                    appCacheData: appCacheData,
                    onUserRemoved: onUserRemoved,
                    onUserAdded: onUserAdded,
                    onUsernameChanged: onUsernameChanged,
                    onLoggedIn: ({required id, required token, required username}) {
                      onLoggedIn(id: id, token: token, username: username, context: context);
                    },
                    onSelectedUserChanged: onSelectedUserChanged,
                    dragHandle: const BottomSheetDragHandle());
              },
            );
          }
        });
  }
}