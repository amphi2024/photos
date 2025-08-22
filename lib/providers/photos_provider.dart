import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_cache.dart';
import 'package:photos/models/app_storage.dart';
import '../models/photo.dart';
import '../models/sort_option.dart';

class PhotosState {
  final Map<String, Photo> photos;
  final List<String> idList;
  final List<String> trash;

  PhotosState(this.photos, this.idList, this.trash);

  void sortPhotos() {
    idList.sortPhotos(appCacheData.sortOption("!PHOTOS"), photos);
  }

  void sortTrash() {
    trash.sortPhotos(appCacheData.sortOption("!TRASH"), photos);
  }

}

class PhotosNotifier extends StateNotifier<PhotosState> {
  PhotosNotifier() : super(PhotosState({}, [], []));

  void insertPhoto(Photo photo) {
    final photos = {...state.photos, photo.id: photo};
    final photoIdList = state.idList.contains(photo.id) ? [...state.idList] : [...state.idList, photo.id];
    final newState = PhotosState(photos, photoIdList, [...state.trash]);
    newState.sortPhotos();
    state = newState;
  }

  void movePhotosToTrash(List<String> list) {
    final photoIdList = state.idList.where((id) => !list.contains(id)).toList();
    final trash = [
      ...state.trash,
      ...list.where((id) => !state.trash.contains(id)),
    ];
    final photos = {...state.photos};
    trash.sortPhotos(appCacheData.sortOption("!TRASH"), photos);
    state = PhotosState(photos, photoIdList, trash);
  }

  void restorePhotos(List<String> list) {
    final idList = [
      ...state.idList,
      ...list.where((id) => !state.idList.contains(id)),
    ];
    final trash = state.trash.where((id) => !list.contains(id)).toList();
    final photos = {...state.photos};
    idList.sortPhotos(appCacheData.sortOption("!PHOTOS"), photos);
    state = PhotosState(photos, idList, trash);
  }

  void deletePhotos(List<String> list) {
    final photos = {...state.photos}..removeWhere((key, value) => list.contains(key));
    final idList = state.idList.where((id) => !list.contains(id)).toList();
    final trash = state.trash.where((id) => !list.contains(id)).toList();
    state = PhotosState(photos, idList, trash);
  }

  void clear() {
    state = PhotosState({}, [], []);
  }

  void sortPhotos() {
    final state1 = PhotosState({...state.photos}, [...state.idList], [...state.trash]);
    state1.sortPhotos();
    state = state1;
  }

  void sortTrash() {
    final state1 = PhotosState({...state.photos}, [...state.idList], [...state.trash]);
    state1.sortTrash();
    state = state1;
  }

  void init() {
    final Map<String, Photo> photos = {};
    final List<String> photoIdList = [];
    final List<String> trash = [];
    var directory = Directory(appStorage.photosPath);
    if(!directory.existsSync()) {
      return;
    }
    DateTime currentDate = DateTime.now();
    DateTime dateBeforeDays = currentDate.subtract(const Duration(days: 30));
    for(var subDirectory in directory.listSync()) {
      if(subDirectory is Directory) {
        for(var subDirectory2 in subDirectory.listSync()) {
          if(subDirectory2 is Directory) {
            for(var directory in subDirectory2.listSync()) {
              if(directory is Directory) {
                var id = PathUtils.basename(directory.path);
                final photo = Photo.fromId(id);
                photos[id] = photo;
                if(photo.deleted == null) {
                  photoIdList.add(photo.id);
                }
                else {
                  if(photo.deleted!.isBefore(dateBeforeDays)) {
                    photo.delete(upload: false);
                  }
                  else {
                    trash.add(photo.id);
                  }
                }
              }
            }
          }
        }
      }
    }

    state = PhotosState(photos, photoIdList, trash);
  }

}

final photosProvider = StateNotifierProvider<PhotosNotifier, PhotosState>((ref) {
  return PhotosNotifier();
});

extension PhotoNullSafeExtension on Map<String, Photo> {
  Photo get(String id) {
    return this[id] ?? Photo.fromId(id);
  }
}

extension SortEx on List {
  void sortPhotos(String sortOption, Map<String, Photo> map) {
    switch(sortOption) {
      case SortOption.date:
        sort((a, b) {
          return map.get(a).date.compareTo(map.get(b).date);
        });
        break;
      case SortOption.created:
        sort((a, b) {
          return map.get(a).created.compareTo(map.get(b).created);
        });
        break;
      case SortOption.modified:
        sort((a, b) {
          return map.get(a).modified.compareTo(map.get(b).modified);
        });
        break;
      case SortOption.deleted:
        sort((a, b) {
          return map.get(a).deleted!.compareTo(map.get(b).deleted!);
        });
        break;
      case SortOption.title:
        sort((a, b) {
          return map.get(a).title.toLowerCase().compareTo(map.get(b).title.toLowerCase());
        });
        break;
      case SortOption.dateDescending:
        sort((a, b) {
          return map.get(b).date.compareTo(map.get(a).date);
        });
        break;
      case SortOption.createdDescending:
        sort((a, b) {
          return map.get(b).created.compareTo(map.get(a).created);
        });
        break;
      case SortOption.modifiedDescending:
        sort((a, b) {
          return map.get(b).modified.compareTo(map.get(a).modified);
        });
        break;
      case SortOption.deletedDescending:
        sort((a, b) {
          return map.get(b).deleted!.compareTo(map.get(a).deleted!);
        });
        break;
      case SortOption.titleDescending:
        sort((a, b) {
          return map.get(b).title.toLowerCase().compareTo(map.get(a).title.toLowerCase());
        });
        break;
    }
  }
}