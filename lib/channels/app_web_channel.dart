import 'dart:convert';
import 'dart:io';

import 'package:amphi/models/app_web_channel_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:photos/models/album.dart';
import 'package:photos/models/app_settings.dart';
import 'package:photos/models/app_storage.dart';
import 'package:photos/models/photo.dart';
import 'package:photos/models/transfer.dart';
import 'package:photos/providers/transfers_provider.dart';
import 'package:web_socket_channel/io.dart';

final appWebChannel = AppWebChannel.getInstance();

class AppWebChannel extends AppWebChannelCore {
  static final AppWebChannel _instance = AppWebChannel._internal();

  AppWebChannel._internal();

  static AppWebChannel getInstance() => _instance;

  @override
  String get serverAddress => appSettings.serverAddress;

  @override
  String get appType => "photos";

  @override
  String get token => appStorage.selectedUser.token;

  static const int failedToConnect = -1;
  static const int failedToAuth = -2;

  late void Function(UpdateEvent) onWebSocketEvent;

  @override
  void setupWebsocketChannel(String serverAddress) async {
    webSocketChannel = IOWebSocketChannel.connect(serverAddress, headers: {"Authorization": appStorage.selectedUser.token});

    webSocketChannel?.stream.listen((message) async {
      Map<String, dynamic> jsonData = jsonDecode(message);
      UpdateEvent updateEvent = UpdateEvent.fromJson(jsonData);
      onWebSocketEvent(updateEvent);

    }, onDone: () {
      connected = false;
    }, onError: (d) {
      connected = false;
    }, cancelOnError: true);
  }

  void getEvents({required void Function(List<UpdateEvent>) onResponse}) async {
    List<UpdateEvent> list = [];
    final response = await get(
      Uri.parse("$serverAddress/photos/events"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
    );
    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
      for (Map<String, dynamic> map in decoded) {
        UpdateEvent updateEvent = UpdateEvent.fromJson(map);
        list.add(updateEvent);
      }
      onResponse(list);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      appStorage.selectedUser.token = "";
    }
  }
  
  void acknowledgeEvent(UpdateEvent updateEvent) async {
    Map<String, dynamic> data = {
      'value': updateEvent.value,
      'action': updateEvent.action,
    };

    String postData = json.encode(data);

    await delete(
      Uri.parse("${appSettings.serverAddress}/photos/events"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appStorage.selectedUser.token},
      body: postData,
    );
  }

  Future<void> uploadPhotoInfo({required Photo photo}) async {
    final updateEvent = UpdateEvent(action: UpdateEvent.uploadPhoto, value: photo.id);
    await uploadJson(url: "$serverAddress/photos/${photo.id}/info", jsonBody: jsonEncode(photo.data), updateEvent: updateEvent);
  }

  Future<void> uploadPhoto({required Photo photo, void Function()? onSuccess, void Function(int?)? onFailed, required WidgetRef ref}) async {
    await uploadFile(url: "$serverAddress/photos/${photo.id}", filePath: photo.photoPath, headers: {"X-File-Extension": photo.mimeType.split("/").last}, onSuccess: () {
      ref.read(transfersProvider.notifier).removeItem(photo.id);
      onSuccess?.call();
    }, onFailed: (code) {
      ref.read(transfersProvider.notifier).insertItem(Transfer(id: photo.id, title: photo.title, received: 1, total: 1, error: true, upload: true));
      onFailed?.call(code);
    }, onProgress: (sent, total) {
      ref.read(transfersProvider.notifier).insertItem(Transfer(id: photo.id, title: photo.title, received: sent, total: total, upload: true));
    });
  }

  Future<void> downloadPhotoFile({required Photo photo, void Function()? onSuccess, void Function(int?)? onFailed, required WidgetRef ref}) async {
    await downloadFile(url: "$serverAddress/photos/${photo.id}", filePath: photo.photoPath, onSuccess: () {
      ref.read(transfersProvider.notifier).removeItem(photo.id);
      onSuccess?.call();
    }, onFailed: (code) {
      ref.read(transfersProvider.notifier).insertItem(Transfer(id: photo.id, title: photo.title, received: 1, total: 1, error: true, upload: false));
      onFailed?.call(code);
    }, onProgress: (received, total) {
      ref.read(transfersProvider.notifier).insertItem(Transfer(id: photo.id, title: photo.title, received: received, total: total, upload: false));
    });
  }

  Future<void> downloadPhotoThumbnail({required Photo photo, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await get(
        Uri.parse("$serverAddress/photos/${photo.id}/thumbnail"),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token},
      );
      if (response.statusCode == 200) {
        File file = File(photo.thumbnailPath);
        await file.writeAsBytes(response.bodyBytes, flush: true);
        if (onSuccess != null) {
          onSuccess();
        }
      }
      else if (onFailed != null) {
        onFailed(response.statusCode);
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  Future<void> downloadPhotoInfo({required String id, required void Function(Map<String, dynamic>) onSuccess}) async {
    await downloadJson(
      url: "$serverAddress/photos/$id/info",
      onSuccess: onSuccess
    );
  }

  Future<void> deletePhoto({required Photo photo}) async {
    final updateEvent = UpdateEvent(action: UpdateEvent.deletePhoto, value: photo.id);
    await simpleDelete(url: "$serverAddress/photos/${photo.id}", updateEvent: updateEvent);
  }

  Future<void> getItems({required String url, required void Function(List<String>) onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
      );
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        onSuccess(list.map((item) => item as String).toList());
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }
  
  Future<void> uploadAlbum({required Album album}) async {
    final updateEvent = UpdateEvent(action: UpdateEvent.uploadAlbum, value: album.id);
    await uploadJson(url: "$serverAddress/photos/albums/${album.id}", jsonBody: jsonEncode(album.data), updateEvent: updateEvent);
  }

  Future<void> deleteAlbum({required Album album}) async {
    final updateEvent = UpdateEvent(action: UpdateEvent.deleteAlbum, value: album.id);
    await simpleDelete(url: "$serverAddress/photos/albums/${album.id}", updateEvent: updateEvent);
  }

  Future<void> downloadAlbum({required String id, required void Function(Album) onSuccess}) async {
    await downloadJson(url: "$serverAddress/photos/albums/$id", onSuccess: (data) async {
      final album = Album.fromFilename("$id.album");
      album.data = data;
      await album.save(upload: false);
      onSuccess(album);
    });
  }

  Future<void> getSha256FromPhoto({required String id, required void Function(String) onSuccess, required void Function(int?) onFailed}) async {
    try {
      final response = await get(
        Uri.parse("$serverAddress/photos/$id/sha256"),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token},
      );
      if (response.statusCode == 200) {
        onSuccess(utf8.decode(response.bodyBytes));
      }
      else {
        onFailed(response.statusCode);
      }
    } catch (e) {
      onFailed(null);
    }
  }
}
