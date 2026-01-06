import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/fragment_index.dart';

class FragmentIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return FragmentIndex.photos;
  }

  void set(int index) {
    state = index;
  }
}

final fragmentIndexProvider = NotifierProvider<FragmentIndexNotifier, int>(FragmentIndexNotifier.new);

class TitleMinimizedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void set(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }
}

final titleMinimizedProvider = NotifierProvider<TitleMinimizedNotifier, bool>(TitleMinimizedNotifier.new);

class CurrentAlbumIdNotifier extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void set(String id) {
    state = id;
  }

  void clear() {
    state = "";
  }
}

final currentAlbumIdProvider = NotifierProvider<CurrentAlbumIdNotifier, String>(CurrentAlbumIdNotifier.new);

class SelectedItemsNotifier extends Notifier<List<String>?> {

  @override
  List<String>? build() {
    return null;
  }

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

final selectedItemsProvider = NotifierProvider<SelectedItemsNotifier, List<String>?>(SelectedItemsNotifier.new);