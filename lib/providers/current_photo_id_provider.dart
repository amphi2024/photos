import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentPhotoIdNotifier extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void set(String id) {
    state = id;
  }
}

final currentPhotoIdProvider = NotifierProvider<CurrentPhotoIdNotifier, String>(CurrentPhotoIdNotifier.new);