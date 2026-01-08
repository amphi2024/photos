import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/photo.dart';
import 'package:photos/providers/photos_provider.dart';

import '../channels/app_web_channel.dart';
import '../providers/albums_provider.dart';


final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {
  static final AppStorage _instance = AppStorage._internal();
  AppStorage._internal();

  late String themesPath;
  late String libraryPath;
  late String albumsPath;

  static AppStorage getInstance() => _instance;

  String get databasePath => PathUtils.join(selectedUser.storagePath, "photos.db");

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");

    // TODO: change it to library when the app is ready for update
    libraryPath = PathUtils.join(selectedUser.storagePath, "photos");
    albumsPath = PathUtils.join(selectedUser.storagePath, "albums");

    createDirectoryIfNotExists(themesPath);
    createDirectoryIfNotExists(libraryPath);
    createDirectoryIfNotExists(albumsPath);
  }

  Future<void> syncDataFromEvents(WidgetRef ref) async {
    if (appWebChannel.token.isNotEmpty) {
      appWebChannel.getEvents(onSuccess: (updateEvents) async {
        for (UpdateEvent updateEvent in updateEvents) {
          syncData(updateEvent, ref);
        }
      });
    }
  }

  Future<void> syncData(UpdateEvent updateEvent, WidgetRef ref) async {
    final value = updateEvent.value;

    switch (updateEvent.action) {
      case UpdateEvent.uploadPhoto:
        await appWebChannel.downloadPhotoInfo(id: value, onSuccess: (data) {
          final photo = Photo.fromMap(data);
          photo.save(upload: false);
          if(photo.deleted != null) {
            ref.read(photosProvider.notifier).movePhotosToTrash([photo.id]);
          }
          else {
            ref.read(photosProvider.notifier).insertPhoto(photo);
          }
        });
        break;
      case UpdateEvent.uploadAlbum:
        await appWebChannel.downloadAlbum(id: value, onSuccess: (album) {
          ref.read(albumsProvider.notifier).insertAlbum(album);
        });
        break;
      case UpdateEvent.deletePhoto:
        final photo = ref.read(photosProvider).photos.get(value);
        await photo.delete(upload: false);
        ref.read(photosProvider.notifier).deletePhotos([photo.id]);
        break;
      case UpdateEvent.deleteAlbum:
        final album = ref.read(albumsProvider).albums.get(value);
        await album.delete(upload: false);
        ref.read(albumsProvider.notifier).deleteAlbums([album.id]);
        break;
    }

    appWebChannel.acknowledgeEvent(updateEvent);
  }

  Future<void> refreshDataWithServer(WidgetRef ref) async {
    await appWebChannel.getItems(url: "${appWebChannel.serverAddress}/photos", onSuccess: (idList) async {

      for(var id in ref.read(photosProvider).idList) {
        final photo = ref.read(photosProvider).photos.get(id);
        await appWebChannel.uploadPhotoInfo(photo: photo);
        await appWebChannel.uploadPhoto(photo: photo, ref: ref);
        // final infoFile = File(PathUtils.join(photo.path, "info.json"));
        // if(!infoFile.existsSync()) {
        //   await appWebChannel.downloadPhotoInfo(id: id, onSuccess: (data) async {
        //     photo.data = data;
        //     photo.getPhotoPath();
        //     await appWebChannel.downloadPhotoThumbnail(photo: photo);
        //     await photo.save(upload: false);
        //     //await appWebChannel.downloadPhotoFile(photo: photo, ref: ref);
        //     ref.read(photosProvider.notifier).insertPhoto(photo);
        //   });
        // }
        // await appWebChannel.getSha256FromPhoto(id: id, onSuccess: (sha256) async {
        //   if(photo.sha256 != sha256) {
        //     await appWebChannel.uploadPhoto(photo: photo, ref: ref);
        //   }
        // }, onFailed: (code) async {
        //   await appWebChannel.uploadPhoto(photo: photo, ref: ref);
        // });
      }

      // for(var id in idList) {
      //   final photo = ref.read(photosProvider).photos.get(id);
      //   final valid = await photo.verifySha256();
      //   if(!valid) {
      //     await appWebChannel.downloadPhotoInfo(id: id, onSuccess: (data) async {
      //       photo.data = data;
      //       photo.getPhotoPath();
      //       await appWebChannel.downloadPhotoThumbnail(photo: photo);
      //       await photo.save(upload: false);
      //       //await appWebChannel.downloadPhotoFile(photo: photo, ref: ref);
      //       ref.read(photosProvider.notifier).insertPhoto(photo);
      //     });
      //   }
      // }

    });

    await appWebChannel.getItems(url: "${appWebChannel.serverAddress}/photos/albums", onSuccess: (ids) async {

      // for(var id in ref.read(albumsProvider).idList) {
      //   if(!ids.contains(id)) {
      //     final album = ref.read(albumsProvider).albums[id];
      //     if(album != null) {
      //       await appWebChannel.uploadAlbum(album: album);
      //     }
      //   }
      // }
      //
      // for(var id in ids) {
      //   if(!ref.read(albumsProvider).idList.contains(id)) {
      //     await appWebChannel.downloadAlbum(id: id, onSuccess: (album) {
      //       ref.read(albumsProvider.notifier).insertAlbum(album);
      //     });
      //   }
      //
      // }

    });

  }

}