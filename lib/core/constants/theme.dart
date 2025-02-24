import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import '/core/constants/font_family.dart';

final ThemeData themeData = ThemeData(
  cardColor: Colors.white,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.grey,
    selectionColor: Colors.grey.withOpacity(0.3),
    selectionHandleColor: Colors.grey.withOpacity(0.3),
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: HavkaColors.green,
    onPrimary: HavkaColors.green,
    secondary: HavkaColors.green,
    onSecondary: HavkaColors.green,
    error: HavkaColors.error,
    onError: HavkaColors.error,
    background: HavkaColors.cream,
    onBackground: HavkaColors.cream,
    surface: HavkaColors.cream,
    onSurface: HavkaColors.black,
  ),
  fontFamily: FontFamily.roboto,
  textTheme: TextTheme(
    labelLarge: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
    ),
    labelMedium: const TextStyle(
      fontSize: 11,
      decoration: TextDecoration.none,
    ),
    labelSmall: TextStyle(
      fontSize: 9,
      color: HavkaColors.grey[100],
      decoration: TextDecoration.none,
    ),
    displayLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: HavkaColors.black,
      decoration: TextDecoration.none,
    ),
    displayMedium: const TextStyle(
      fontSize: 14,
      color: HavkaColors.black,
      decoration: TextDecoration.none,
    ),
    displaySmall: const TextStyle(fontSize: 12),
    titleLarge: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  listTileTheme: const ListTileThemeData(
    textColor: HavkaColors.black,
    tileColor: HavkaColors.cream,
  ),
  brightness: Brightness.light,
  primaryColor: HavkaColors.green,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
);

final ThemeData themeDataDark = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: HavkaColors.green,
    onPrimary: HavkaColors.green,
    secondary: HavkaColors.green,
    onSecondary: HavkaColors.green,
    error: HavkaColors.error,
    onError: HavkaColors.error,
    background: HavkaColors.cream,
    onBackground: HavkaColors.cream,
    surface: HavkaColors.cream,
    onSurface: HavkaColors.black,
  ),
  fontFamily: FontFamily.roboto,
  textTheme: TextTheme(
    labelLarge: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
    ),
    labelMedium: const TextStyle(
      fontSize: 11,
      decoration: TextDecoration.none,
    ),
    labelSmall: TextStyle(
      fontSize: 9,
      color: HavkaColors.grey[100],
      decoration: TextDecoration.none,
    ),
    displayLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: HavkaColors.black,
      decoration: TextDecoration.none,
    ),
    displayMedium: const TextStyle(
      fontSize: 14,
      color: HavkaColors.black,
      decoration: TextDecoration.none,
    ),
    displaySmall: const TextStyle(fontSize: 12),
    titleLarge: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  listTileTheme: const ListTileThemeData(
    textColor: HavkaColors.black,
    tileColor: HavkaColors.cream,
  ),
  brightness: Brightness.light,
  primaryColor: HavkaColors.green,
);
