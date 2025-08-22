import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/fragment_index.dart';

final fragmentIndexProvider = StateProvider<int>((ref) => FragmentIndex.photos);
final titleMinimizedProvider = StateProvider<bool>((ref) => false);
final currentAlbumIdProvider = StateProvider<String>((ref) => "");

class SelectedItemsNotifier extends StateNotifier<List<String>?> {
  SelectedItemsNotifier() : super(null);

  void addId(String id) {
    if(state == null) {
      return;
    }
    if (!state!.contains(id)) {
      state = [...state!, id];
    }
  }

  void removeId(String id) {
    if(state == null) {
      return;
    }
    state = state!.where((e) => e != id).toList();
  }

  void startSelection() {
    state = [];
  }

  void endSelection() {
    state = null;
  }

}

final selectedItemsProvider = StateNotifierProvider<SelectedItemsNotifier, List<String>?>((ref) {
  return SelectedItemsNotifier();
});