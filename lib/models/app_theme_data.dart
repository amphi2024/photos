import 'package:flutter/material.dart';
import 'package:amphi/models/app.dart';

import 'app_theme.dart';

class AppThemeData {
  Color backgroundColor;
  Color textColor;
  Color accentColor;
  Color inactiveColor;
  Color noteBackgroundColor;
  Color noteTextColor;
  Color floatingButtonBackground;
  Color floatingButtonIconColor;
  Color checkBoxColor;
  Color checkBoxCheckColor;
  Color errorColor;
  Color menuBackground;

  AppThemeData({
    this.backgroundColor = ThemeModel.midnight,
    this.textColor = ThemeModel.white,
    this.accentColor = ThemeModel.cherryBlossom,
    this.inactiveColor = ThemeModel.inactiveGray,
    this.noteBackgroundColor = ThemeModel.charCoal,
    this.noteTextColor = ThemeModel.white,
    this.floatingButtonBackground = ThemeModel.white,
    this.floatingButtonIconColor = ThemeModel.cherryBlossom,
    this.checkBoxColor = ThemeModel.cherryBlossom,
    this.checkBoxCheckColor = ThemeModel.white,
    this.errorColor = ThemeModel.red,
    this.menuBackground = ThemeModel.charCoal
  });

  ThemeData themeData({required Brightness brightness, required BuildContext context}) {
    return ThemeData(
      inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: inactiveColor, fontSize: 15),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: accentColor, style: BorderStyle.solid, width: 2)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: backgroundColor, style: BorderStyle.solid))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              elevation: 0,
              padding: const EdgeInsets.only(left: 10, right: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              textStyle: TextStyle(
                  color: accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))),
      dialogBackgroundColor: backgroundColor,
      dividerColor: inactiveColor,
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: backgroundColor,
        color: backgroundColor,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(10)
       )
      ),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
              surfaceTintColor: WidgetStateProperty.all(backgroundColor))),
      shadowColor:
          backgroundColor.green + backgroundColor.blue + backgroundColor.red >
                  381
              ? Colors.grey.withOpacity(0.5)
              : Colors.black.withOpacity(0.5),
      iconTheme: IconThemeData(color: accentColor, size: App.isWideScreen(context) || App.isDesktop() ? 25 : 15),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return checkBoxCheckColor;
          } else {
            return ThemeModel.transparent;
          }
        }),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return checkBoxColor;
          } else {
            return ThemeModel.transparent;
          }
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
          // backgroundColor: backgroundColor.withAlpha(245),
          // surfaceTintColor: backgroundColor.withAlpha(245),
          toolbarHeight: 40,
          titleSpacing: 0.0,
          iconTheme: IconThemeData(color: accentColor, size: 20)),
      disabledColor: inactiveColor,
      highlightColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: noteBackgroundColor,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: floatingButtonBackground,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.vertical,
        contentTextStyle: TextStyle(
          color: floatingButtonIconColor
        )
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accentColor,
        onPrimary: textColor,
        secondary: accentColor,
        onSecondary: textColor,
        onError: accentColor,
        error: ThemeModel.red,
        surface: noteBackgroundColor,
        onSurface: noteTextColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: floatingButtonBackground,
          focusColor: floatingButtonIconColor,
          iconSize: 35),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
            color: textColor, fontSize: 15, overflow: TextOverflow.ellipsis),
      ),
      dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          titleTextStyle: TextStyle(
              color: textColor, fontSize: 17.5, fontWeight: FontWeight.bold)),
      navigationDrawerTheme: NavigationDrawerThemeData(
          backgroundColor: menuBackground),
    );
  }
}