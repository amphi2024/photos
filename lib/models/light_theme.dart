import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_theme_data.dart';

class LightTheme extends AppThemeData {

  LightTheme(
      {
        super.backgroundColor = AppTheme.lightGray,
        super.textColor = AppTheme.midnight,
        super.accentColor = AppTheme.cherryBlossom,
        super.inactiveColor = AppTheme.inactiveGray,
        super.noteBackgroundColor = AppTheme.white,
        super.noteTextColor = AppTheme.midnight,
        super.floatingButtonBackground = AppTheme.white,
        super.floatingButtonIconColor = AppTheme.cherryBlossom,
        super.checkBoxColor = AppTheme.cherryBlossom,
        super.checkBoxCheckColor = AppTheme.white,
        super.errorColor = AppTheme.red,
        super.menuBackground =  const Color.fromRGBO(235, 235, 235, 1)
      });
  ThemeData toThemeData(BuildContext context) {
    return themeData(
        brightness: Brightness.light, context: context);
  }
}