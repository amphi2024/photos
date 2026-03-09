import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_cache.dart';
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

  bool ctrlPressed = false;
  bool shiftPressed = false;

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

  void addAll(List<String> items) {
    final list = [...state!];
    list.addAll(items);
    state = list;
  }

}

final selectedItemsProvider = NotifierProvider<SelectedItemsNotifier, List<String>?>(SelectedItemsNotifier.new);

const maximumAxisCount = 15;
const maximumAxisCountDouble = 15.0;

class AxisCountNotifier extends Notifier<int> {
  @override
  int build() {
    return appCacheData.axisCount;
  }

  void set(int value) {
    state = value;
  }
}

final axisCountProvider = NotifierProvider<AxisCountNotifier, int>(AxisCountNotifier.new);

class SidebarWidthNotifier extends Notifier<double> {
  @override
  double build() {
    return 200;
  }

  void set(double value) {
    if(value <= 50 || value >= 500) {
      return;
    }
    state = value;
  }
}

final sidebarWidthProvider = NotifierProvider<SidebarWidthNotifier, double>(SidebarWidthNotifier.new);