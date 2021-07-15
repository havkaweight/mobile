import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/user_devices_screen.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';

class ChildWidget extends StatelessWidget {
  final AvailableScreen screen;
  const ChildWidget({Key key, this.screen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (screen == AvailableScreen.Profile) {
      widget = ProfileScreen();
    } else if (screen == AvailableScreen.Fridge) {
      widget = UserProductsScreen();
    } else if (screen == AvailableScreen.Scale) {
      widget = ScaleScreen();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget
      ),
    );
  }
}

enum AvailableScreen { Profile, Fridge, Scale }