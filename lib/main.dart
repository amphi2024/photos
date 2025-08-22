import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:photos/channels/app_method_channel.dart';
import 'package:photos/models/app_settings.dart';
import 'package:photos/models/app_storage.dart';
import 'package:photos/pages/wide_main_page.dart';
import 'package:photos/providers/albums_provider.dart';
import 'package:photos/providers/photos_provider.dart';
import 'channels/app_web_channel.dart';
import 'models/app_cache.dart';
import 'models/app_theme.dart';
import 'pages/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (appSettings.useOwnServer) {
        if (!appWebChannel.connected) {
          appWebChannel.connectWebSocket();
        }
        appStorage.syncDataFromEvents(ref);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool initialized = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    appWebChannel.onWebSocketEvent = (event) {
      appStorage.syncData(event, ref);
    };
    appCacheData.getData();
    appStorage.initialize(() {
      appSettings.getData();
      ref.read(photosProvider.notifier).init();
      ref.read(albumsProvider.notifier).init(ref.read(photosProvider).photos);
      setState(() {
        initialized = true;
      });

      if (appSettings.useOwnServer) {
        appWebChannel.connectWebSocket();
        appStorage.syncDataFromEvents(ref);
      }

      if (App.isDesktop()) {
        doWhenWindowReady(() {
          appWindow.minSize = const Size(550, 300);
          appWindow.size =
              Size(appCacheData.windowWidth, appCacheData.windowHeight);
          appWindow.alignment = Alignment.center;
          appWindow.title = "Photos";
          appWindow.show();
        });
      }
    });

    appWebChannel.getDeviceInfo();
    if(Platform.isAndroid) {
      appMethodChannel.getSystemVersion();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appSettings.appTheme.lightTheme.toThemeData(context),
        darkTheme: appSettings.appTheme.darkTheme.toThemeData(context),
        locale: appSettings.locale,
        localizationsDelegates: const [
          LocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: App.isWideScreen(context) || App.isDesktop() ? const WideMainPage() : const MainPage(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: AppTheme.lightGray),
        darkTheme: ThemeData(scaffoldBackgroundColor: AppTheme.charCoal),
        home: const Scaffold(),
      );
    }
  }
}
