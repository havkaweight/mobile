import 'package:flutter/material.dart';
import 'colors.dart';
import 'font_family.dart';

final ThemeData themeData = ThemeData(
  fontFamily: FontFamily.roboto,
  textTheme: const TextTheme(
    button: TextStyle(fontSize: 13),
    headline3: TextStyle(fontSize: 12),
    headline4: TextStyle(fontSize: 10)
  ),
  brightness: Brightness.light,
  primaryColor: HavkaColors.green,
  primaryColorBrightness: Brightness.light,
  accentColor: HavkaColors.green,
  accentColorBrightness: Brightness.light,
  backgroundColor: HavkaColors.cream
);

final ThemeData themeDataDark = ThemeData(
  fontFamily: FontFamily.roboto,
  textTheme: const TextTheme(
      button: TextStyle(fontSize: 13),
      headline3: TextStyle(fontSize: 12),
      headline4: TextStyle(fontSize: 10)
  ),
  brightness: Brightness.dark,
  primaryColor: HavkaColors.green,
  primaryColorBrightness: Brightness.dark,
  accentColor: HavkaColors.green,
  accentColorBrightness: Brightness.dark,
  backgroundColor: HavkaColors.cream
);