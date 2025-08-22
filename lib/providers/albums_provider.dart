import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_cache.dart';
import 'package:photos/models/app_storage.dart';
import 'package:photos/providers/photos_provider.dart';
import '../models/album.dart';
import '../models/photo.dart';
import '../models/sort_option.dart';

class AlbumsState {

  final Map<String, Album> albums;
  final List<String> idList;

  AlbumsState(this.albums, this.idList);

  Album getAlbum(int index) {
    return albums.get(idList[index]);
  }

  void sortAlbums() {
    switch(appCacheData.sortOption("!ALBUMS")) {
      case SortOption.created:
        idList.sort((a, b) {
          return albums.get(a).created.compareTo(albums.get(b).created);
        });
        break;
      case SortOption.modified:
        idList.sort((a, b) {
          return albums.get(a).modified.compareTo(albums.get(b).modified);
        });
        break;
      case SortOption.title:
        idList.sort((a, b) {
          return albums.get(a).title.toLowerCase().compareTo(albums.get(b).title.toLowerCase());
        });
        break;
      case SortOption.createdDescending:
        idList.sort((a, b) {
          return albums.get(b).created.compareTo(albums.get(a).created);
        });
        break;
      case SortOption.modifiedDescending:
        idList.sort((a, b) {
          return albums.get(b).modified.compareTo(albums.get(a).modified);
        });
        break;
      case SortOption.titleDescending:
        idList.sort((a, b) {
          return albums.get(b).title.toLowerCase().compareTo(albums.get(a).title.toLowerCase());
        });
        break;
    }
  }
}

class AlbumsNotifier extends StateNotifier<AlbumsState> {
  AlbumsNotifier() : super(AlbumsState({}, []));

  void insertAlbum(Album album) {
    final albums = {...state.albums, album.id: album};
    final idList = state.idList.contains(album.id) ? [...state.idList] : [...state.idList, album.id];
    final state1 = AlbumsState(albums, idList);
    state1.sortAlbums();
    state = state1;
  }

  void deleteAlbums(List<String> list) {
    final albums = {...state.albums}..removeWhere((key, value) => list.contains(key));
    final idList = state.idList.where((id) => !list.contains(id)).toList();
    final state1 = AlbumsState(albums, idList);
    state = state1;
  }

  void sortAlbums() {
    final state1 = AlbumsState({...state.albums}, [...state.idList]);
    state1.sortAlbums();
    state = state1;
  }

  void init(Map<String, Photo> photos) {
    final Map<String, Album> albums = {};
    final List<String> idList = [];
    var albumsDirectory = Directory(appStorage.albumsPath);
    if(!albumsDirectory.existsSync()) {
      return;
    }
    for(var file in albumsDirectory.listSync()) {
      if(file is File) {
        final filename = PathUtils.basename(file.path);
        final album = Album.fromFilename(filename);
        album.photos.sortPhotos(appCacheData.sortOption(album.id), photos);
        albums[album.id] = album;
        idList.add(album.id);
      }
    }
    
    state = AlbumsState(albums, idList);
  }
}

final albumsProvider = StateNotifierProvider<AlbumsNotifier, AlbumsState>((ref) {
  return AlbumsNotifier();
});

extension AlbumNullSafeExtension on Map<String, Album> {
  Album get(String id) {
    return this[id] ?? Album.fromFilename("$id.album");
  }
}