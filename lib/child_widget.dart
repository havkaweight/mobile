import 'package:flutter/material.dart';
import 'package:health_tracker/product_measurement_screen.dart';
import 'package:health_tracker/profile_screen.dart';
import 'package:health_tracker/test_screen.dart';
import 'package:health_tracker/user_devices_screen.dart';
import 'package:health_tracker/user_products_screen.dart';

import 'components/bubbles.dart';

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
    } else if (screen == AvailableScreen.Devices) {
      widget = UserDevicesScreen();
    } else {
      widget = MeasurementScreen();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget
      ),
    );
  }
}

enum AvailableScreen { Profile, Fridge, Devices, Measure }