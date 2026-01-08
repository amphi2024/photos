import 'package:amphi/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';
import '../database/database_helper.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';
import '../providers/albums_provider.dart';
import '../providers/photos_provider.dart';

void onUserRemoved(WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.initPaths();
  await appSettings.getData();
  appWebChannel.connectWebSocket();
  await databaseHelper.notifySelectedUserChanged();
  await ref.read(photosProvider.notifier).rebuild();
  ref.read(albumsProvider.notifier).rebuild();
  appStorage.refreshDataWithServer(ref);
}

void onUserAdded(WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.initPaths();
  await appSettings.getData();
  await databaseHelper.notifySelectedUserChanged();
  await ref.read(photosProvider.notifier).rebuild();
  ref.read(albumsProvider.notifier).rebuild();
}

void onUsernameChanged(WidgetRef ref) {
}

void onSelectedUserChanged(User user, WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.selectedUser = user;
  appStorage.initPaths();
  await appSettings.getData();
  await databaseHelper.notifySelectedUserChanged();
  await ref.read(photosProvider.notifier).rebuild();
  ref.read(albumsProvider.notifier).rebuild();
  appStorage.syncDataFromEvents(ref);
}

void onLoggedIn({required String id, required String token, required String username, required BuildContext context, required WidgetRef ref}) async {
  appStorage.selectedUser.id = id;
  Navigator.popUntil(
    context,
        (Route<dynamic> route) => route.isFirst,
  );
  appStorage.selectedUser.name = username;
  appStorage.selectedUser.token = token;
  await appStorage.saveSelectedUserInformation();
  await databaseHelper.notifySelectedUserChanged();
  appStorage.refreshDataWithServer(ref);
}