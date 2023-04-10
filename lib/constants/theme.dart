import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/constants/font_family.dart';

final ThemeData themeData = ThemeData(
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
);

final ThemeData themeDataDark = ThemeData(
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
  textTheme: const TextTheme(
    labelSmall: TextStyle(fontSize: 9),
    labelMedium: TextStyle(fontSize: 10),
    labelLarge: TextStyle(fontSize: 11),
    displaySmall: TextStyle(fontSize: 12),
    displayMedium: TextStyle(fontSize: 14),
    displayLarge: TextStyle(fontSize: 16),
  ),
  brightness: Brightness.light,
  primaryColor: HavkaColors.green,
);
