import 'package:flutter/material.dart';

final appState = AppState.getInstance();

class AppState {

  static final AppState _instance = AppState._internal();

  AppState._internal();

  static AppState getInstance() => _instance;

  void Function() requestScrollToTop = () {};

  final pageController = PageController();

  late void Function(void Function()) onSettingsChanged;
  late void Function() onServerAddressChanged;

}