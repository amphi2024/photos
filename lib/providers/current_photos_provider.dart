import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';

import '../models/fragment_index.dart';
import 'albums_provider.dart';

typedef PhotoViewData = ({List<String> idList, String placeholderKey});

final currentPhotoViewProvider = Provider<PhotoViewData>((ref) {
  final fragmentIndex = ref.watch(fragmentIndexProvider);

  return switch (fragmentIndex) {
    FragmentIndex.photos => (
    idList: ref.watch(photosProvider).idList,
    placeholderKey: "@no_photos",
    ),
    FragmentIndex.trash => (
    idList: ref.watch(photosProvider).trash,
    placeholderKey: "@no_photos_trash",
    ),
    _ => (
    idList: ref.watch(albumsProvider).albums.get(ref.watch(currentAlbumIdProvider)).photos,
    placeholderKey: "@no_photos_album",
    ),
  };
});