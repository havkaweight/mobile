import 'package:flutter/material.dart';
import '../../ui/screens/profile_screen.dart';
import '../../ui/screens/scale_screen.dart';
import '../../ui/screens/user_products_screen.dart';

class ChildWidget extends StatelessWidget {
  final AvailableScreen screen;
  const ChildWidget({Key? key, required this.screen}) : super(key: key);

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
        padding: const EdgeInsets.all(8.0),
        child: widget
      ),
    );
  }
}

enum AvailableScreen { profile, fridge }