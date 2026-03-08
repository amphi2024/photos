import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/albums_provider.dart';

void removePhotosFromAlbum({required WidgetRef ref, required String albumId, required List<String> selectedItems}) {
  final album = ref.read(albumsProvider).albums.get(albumId);
  album.photos.removeWhere((element) => selectedItems.contains(element));
  album.save();
  ref.read(albumsProvider.notifier).insertAlbum(album);
}