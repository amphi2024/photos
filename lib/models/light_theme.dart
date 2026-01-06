import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_theme_data.dart';

class LightTheme extends AppThemeData {

  LightTheme(
      {
        super.backgroundColor = ThemeModel.lightGray,
        super.textColor = ThemeModel.midnight,
        super.accentColor = ThemeModel.cherryBlossom,
        super.inactiveColor = ThemeModel.inactiveGray,
        super.noteBackgroundColor = ThemeModel.white,
        super.noteTextColor = ThemeModel.midnight,
        super.floatingButtonBackground = ThemeModel.white,
        super.floatingButtonIconColor = ThemeModel.cherryBlossom,
        super.checkBoxColor = ThemeModel.cherryBlossom,
        super.checkBoxCheckColor = ThemeModel.white,
        super.errorColor = ThemeModel.red,
        super.menuBackground =  const Color.fromRGBO(235, 235, 235, 1)
      });
  ThemeData toThemeData(BuildContext context) {
    return themeData(
        brightness: Brightness.light, context: context);
  }
}