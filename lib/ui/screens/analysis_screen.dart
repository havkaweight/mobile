import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/constants/utils.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/widgets/circle_button.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

class AnalysisScreen extends StatefulWidget {

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleButton(text: '1d'),
                  CircleButton(text: '7d'),
                  CircleButton(text: '30d'),
                ]
              )
            ]
          )
        ));
  }
}
