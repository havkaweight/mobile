import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';

class ChildWidget extends StatelessWidget {
  final AvailableScreen screen;
  const ChildWidget({
    super.key,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    Widget? widget;
    if (screen == AvailableScreen.profile) {
      widget = ProfileScreen();
    } else if (screen == AvailableScreen.fridge) {
      widget = UserProductsScreen();
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
  profile,
  fridge,
}
