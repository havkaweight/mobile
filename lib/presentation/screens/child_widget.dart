import 'package:flutter/material.dart';
import '/presentation/screens/profile_screen.dart';
import '/presentation/screens/stats_screen.dart';
import '/presentation/screens/fridge_screen.dart';

class ChildWidget extends StatelessWidget {
  final AvailableScreen screen;
  const ChildWidget({
    super.key,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    Widget? widget;
    if (screen == AvailableScreen.stats) {
      widget = StatsScreen();
    } else if (screen == AvailableScreen.profile) {
      widget = ProfileScreen();
    } else if (screen == AvailableScreen.fridge) {
      widget = FridgeScreen();
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.zero,
        child: widget,
      ),
    );
  }
}

enum AvailableScreen {
  stats,
  profile,
  fridge,
}
