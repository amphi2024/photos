import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linux_csd_buttons/linux_csd_buttons.dart';
import 'package:photos/models/app_storage.dart';

class CsdThemesState {
  final Map<String, CsdTheme> themes;
  final List<String> idList;

  const CsdThemesState(this.themes, this.idList);
}

class CsdThemesNotifier extends Notifier<CsdThemesState> {
  @override
  CsdThemesState build() {
    return const CsdThemesState({}, []);
  }

  static Future<CsdThemesState> initialized() async {
    final Map<String, CsdTheme> themes = {};
    final List<String> idList = [];
    if (Platform.isLinux) {
      final directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "window_button_themes"));
      if (await directory.exists()) {
        await for (final file in directory.list()) {
          if (file is File) {
            try {
              final theme = CsdTheme.fromJson(jsonDecode((await file.readAsString())));
              final id = PathUtils.basenameWithoutExtension(file.path);
              themes[id] = theme;
              idList.add(id);
            } catch (_) {}
          }
        }
      }
    }

    return CsdThemesState(themes, idList);
  }

  Future<void> rebuild() async {
    state = await initialized();
  }

  void insertTheme(String id, CsdTheme theme) {
    final themes = {...state.themes, id: theme};

    final idList = state.idList.contains(id) ? [...state.idList] : [...state.idList, id];

    state = CsdThemesState(themes, idList);
  }

  void deleteTheme(String id) {
    final themes = {...state.themes}..removeWhere((key, value) => key == id);
    final idList = state.idList.where((id1) => id1 != id).toList();

    state = CsdThemesState(themes, idList);
  }
}

final csdThemesProvider = NotifierProvider<CsdThemesNotifier, CsdThemesState>(CsdThemesNotifier.new);