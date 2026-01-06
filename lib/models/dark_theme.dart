import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_theme_data.dart';

class DarkTheme extends AppThemeData {

  DarkTheme(
      {
        super.backgroundColor = ThemeModel.midnight,
        super.textColor = ThemeModel.white,
        super.accentColor = ThemeModel.cherryBlossom,
        super.inactiveColor = ThemeModel.inactiveGray,
        super.noteBackgroundColor = ThemeModel.charCoal,
        super.noteTextColor = ThemeModel.white,
        super.floatingButtonBackground = ThemeModel.white,
        super.floatingButtonIconColor = ThemeModel.cherryBlossom,
        super.checkBoxColor = ThemeModel.cherryBlossom,
        super.checkBoxCheckColor = ThemeModel.white,
        super.errorColor = ThemeModel.red
      });

  ThemeData toThemeData(BuildContext context) {
    return themeData(
      brightness: Brightness.dark, context: context);
  }
}