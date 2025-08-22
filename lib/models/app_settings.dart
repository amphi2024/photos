// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'app_storage.dart';
import 'app_theme.dart';

final appSettings = AppSettings.getInstance();

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  AppSettings._internal();

  static AppSettings getInstance() => _instance;

  late int fragmentIndex;
  // AppTheme   appTheme = AppTheme(
  //     created: DateTime.now(),
  //     modified: DateTime.now()
  // );
  Map<String, dynamic> data = {
    "locale": null,
    "serverAddress": ""
  };
  set localeCode(value) => data["locale"] = value;
  String? get localeCode => data["locale"];
  Locale? locale;
  AppTheme appTheme = AppTheme(created: DateTime.now(), modified: DateTime.now());

  set transparentNavigationBar(value) => data["transparentNavigationBar"] = value;
  bool get transparentNavigationBar => data.putIfAbsent("transparentNavigationBar", () => false);

  set useOwnServer(value) => data["useOwnServer"] = value;
  bool get useOwnServer => data.putIfAbsent("useOwnServer", () => false);

  set serverAddress(value) => data["serverAddress"] = value;
  String get serverAddress => data.putIfAbsent("serverAddress", () => "");

  void getData() {
    try {
      var file = File(appStorage.settingsPath);
      data = jsonDecode(file.readAsStringSync());
      locale = Locale(appSettings.localeCode ?? PlatformDispatcher.instance.locale.languageCode);
    }
    catch(e) {
      locale = Locale(appSettings.localeCode ?? PlatformDispatcher.instance.locale.languageCode);
      save();
    }
  }

  Future<void> save() async {
    File file = File(appStorage.settingsPath);
    file.writeAsString(jsonEncode(data));
  }
}

const int SORT_OPTION_TITLE = 0;
const int SORT_OPTION_CREATE_DATE = 1;
const int SORT_OPTION_MODIFIED_DATE = 2;
const int SORT_OPTION_DELETED_DATE = 3;