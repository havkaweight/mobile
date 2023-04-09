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
