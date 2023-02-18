import 'package:flutter/material.dart';

class HavkaColors {
  HavkaColors._(); // this basically makes it so you can't instantiate this class

  static const Color green = Color(0xFF5BBE78);
  static const Color cream = Color(0xFFFFFdd0);
  static const Map<int, Color> bone = <int, Color> {
    50: Color(0x88EDE88E),
    100: Color(0xFFEDE88E),
    200: Color(0xFFFFFF99),
  };

  static const Map<int, Color> grey = <int, Color> {
    50: Color(0x88E1EDEB),
    100: Color(0xFFE1EDEB),
  };

  // static const Map<int, Color> green = const <int, Color>{
  //   10: const Color(0x115BBE78),
  //   20: const Color(0x335BBE78),
  //   30: const Color(0x555BBE78),
  //   40: const Color(0x775BBE78),
  //   50: const Color(0x995BBE78),
  //   60: const Color(0xAA5BBE78),
  //   70: const Color(0xCC5BBE78),
  //   80: const Color(0xDD5BBE78),
  //   90: const Color(0xEE5BBE78),
  //   100: const Color(0xFF5BBE78)
  // };
}