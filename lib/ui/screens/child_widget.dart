import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';

import 'analysis_screen.dart';

class ChildWidget extends StatelessWidget {
  final AvailableScreen screen;
  const ChildWidget({Key key, this.screen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (screen == AvailableScreen.profile) {
      widget = ProfileScreen();
    } else if (screen == AvailableScreen.fridge) {
      widget = UserProductsScreen();
    } else if (screen == AvailableScreen.analysis) {
      widget = AnalysisScreen();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget
      ),
    );
  }
}

enum AvailableScreen { profile, fridge, analysis }