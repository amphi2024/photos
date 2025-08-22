import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/dialogs/edit_album_dialog.dart';
import 'package:photos/providers/albums_provider.dart';

import '../../models/app_cache.dart';
import '../../models/fragment_index.dart';
import '../../models/sort_option.dart';
import '../../providers/photos_provider.dart';

List<PopupMenuItem> mainPageAppBarPopupMenuItems({required WidgetRef ref, required int fragmentIndex, required BuildContext context}) {
  switch (fragmentIndex) {
    case FragmentIndex.trash:
      var sortOption = appCacheData.sortOption("!TRASH");
      sort() {
        ref.read(photosProvider.notifier).sortTrash();
      }
      return [
        _popupMenuItem(
            title: AppLocalizations.of(context).get("@sort_by_title"),
            ref: ref,
            id: "!TRASH",
            currentSortOption: sortOption,
            sortOption: SortOption.title,
            sortOptionDescending: SortOption.titleDescending,
            sort: sort),
        _popupMenuItem(
            title: AppLocalizations.of(context).get("@sort_by_date"),
            ref: ref,
            id: "!TRASH",
            currentSortOption: sortOption,
            sortOption: SortOption.date,
            sortOptionDescending: SortOption.dateDescending,
            sort: sort),
        _popupMenuItem(
            title: AppLocalizations.of(context).get("@sort_by_deleted"),
            ref: ref,
            id: "!TRASH",
            currentSortOption: sortOption,
            sortOption: SortOption.deleted,
            sortOptionDescending: SortOption.deletedDescending,
            sort: sort)
      ];
    case FragmentIndex.albums:
      return albumsPopupMenuItems(ref: ref, context: context);
    default:
      var sortOption = appCacheData.sortOption("!PHOTOS");
      sort() {
        ref.read(photosProvider.notifier).sortPhotos();
      }
      return [
        _popupMenuItem(
            title: AppLocalizations.of(context).get("@sort_by_title"),
            ref: ref,
            id: "!PHOTOS",
            currentSortOption: sortOption,
            sortOption: SortOption.title,
            sortOptionDescending: SortOption.titleDescending,
            sort: sort),
        _popupMenuItem(
            title: AppLocalizations.of(context).get("@sort_by_date"),
            ref: ref,
            id: "!PHOTOS",
            currentSortOption: sortOption,
            sortOption: SortOption.date,
            sortOptionDescending: SortOption.dateDescending,
            sort: sort)
      ];
  }
}

List<PopupMenuItem> albumsPopupMenuItems({required WidgetRef ref, required BuildContext context, double? height}) {
  var sortOption = appCacheData.sortOption("!ALBUMS");
  sort() {
    ref.read(albumsProvider.notifier).sortAlbums();
  }
  return [
    _popupMenuItem(
        title: AppLocalizations.of(context).get("@sort_by_title"),
        ref: ref,
        id: "!ALBUMS",
        currentSortOption: sortOption,
        sortOption: SortOption.title,
        sortOptionDescending: SortOption.titleDescending,
        sort: sort),
    _popupMenuItem(
        title: AppLocalizations.of(context).get("@sort_by_created"),
        ref: ref,
        id: "!ALBUMS",
        currentSortOption: sortOption,
        sortOption: SortOption.created,
        sortOptionDescending: SortOption.createdDescending,
        sort: sort),
    _popupMenuItem(
        title: AppLocalizations.of(context).get("@sort_by_modified"),
        ref: ref,
        id: "!ALBUMS",
        currentSortOption: sortOption,
        sortOption: SortOption.modified,
        sortOptionDescending: SortOption.modifiedDescending,
        sort: sort)
  ];
}

List<PopupMenuItem> albumPageAppBarPopupMenuItems({required WidgetRef ref, required String id, required BuildContext context}) {
  var sortOption = appCacheData.sortOption(id);
  final album = ref.read(albumsProvider).albums.get(id);
  sort() {
    album.photos.sortPhotos(appCacheData.sortOption(id), ref.read(photosProvider).photos);
    ref.read(albumsProvider.notifier).insertAlbum(album);
  }
  return [
    _popupMenuItem(
        title: AppLocalizations.of(context).get("@sort_by_title"),
        ref: ref,
        id: id,
        currentSortOption: sortOption,
        sortOption: SortOption.title,
        sortOptionDescending: SortOption.titleDescending,
        sort: sort),
    _popupMenuItem(
        title: AppLocalizations.of(context).get("@sort_by_date"),
        ref: ref,
        id: id,
        currentSortOption: sortOption,
        sortOption: SortOption.date,
        sortOptionDescending: SortOption.dateDescending,
        sort: sort),
    PopupMenuItem(child: Text(AppLocalizations.of(context).get("@edit_album")), onTap: () {
      showDialog(context: context, builder: (context) {
        return EditAlbumDialog(
          album: album,
        );
      });
    })
  ];
}

PopupMenuItem _popupMenuItem(
    {required String title,
    required WidgetRef ref,
    required String currentSortOption,
    required String sortOption,
    required String sortOptionDescending,
    required String id,
    required void Function() sort}) {
  return PopupMenuItem(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Visibility(
            visible: currentSortOption == sortOption || currentSortOption == sortOptionDescending,
            child: Icon(currentSortOption == sortOption ? Icons.arrow_upward : Icons.arrow_downward))
      ],
    ),
    onTap: () {
      if (currentSortOption == sortOption) {
        appCacheData.setSortOption(sortOption: sortOptionDescending, id: id);
      } else {
        appCacheData.setSortOption(sortOption: sortOption, id: id);
      }
      sort();
    },
  );
}
