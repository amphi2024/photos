
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/database/database_helper.dart';
import 'package:photos/models/app_cache.dart';
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

class AlbumsNotifier extends Notifier<AlbumsState> {
  @override
  AlbumsState build() {
    return AlbumsState({}, []);
  }

  static Future<AlbumsState> initialized(Map<String, Photo> photos) async {
    final Map<String, Album> albums = {};
    final List<String> idList = [];

    final database = await databaseHelper.database;
    final List<Map<String, dynamic>> list = await database.rawQuery("SELECT * FROM albums", []);

    for(var data in list) {
      final album = Album.fromMap(data);
      album.photos.sortPhotos(appCacheData.sortOption(album.id), photos);
      albums[album.id] = album;
      idList.add(album.id);
    }

    return AlbumsState(albums, idList);
  }

  Future<void> rebuild() async {
    state = await initialized(ref.read(photosProvider).photos);
  }

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
}

final albumsProvider = NotifierProvider<AlbumsNotifier, AlbumsState>(AlbumsNotifier.new);

extension AlbumNullSafeExtension on Map<String, Album> {
  Album get(String id) {
    return this[id] ?? Album(id: "");
  }
}