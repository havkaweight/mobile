import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import '/data/models/pfc_data_item.dart';
import '../widgets/charts/bar_chart_timeline.dart';
import '../widgets/charts/donut_chart.dart';
import '../widgets/charts/line_chart.dart';

class OnboardingScreen1 extends StatefulWidget {
  final int seconds;
  OnboardingScreen1({
    this.seconds = 0,
});
  @override
  _OnboardingScreen1State createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {

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
      backgroundColor: HavkaColors.bone[200],
      body: Center(
        child: Text(
            "Welcome to Havka",
            style: TextStyle(
              fontSize: 30,
            ),
        ),
      ),
    );
  }
}

class OnboardingScreen2 extends StatefulWidget {
  @override
  _OnboardingScreen2State createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2> {
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
      backgroundColor: HavkaColors.bone[200],
      body: Center(
        child: Text(
          "3",
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen3 extends StatefulWidget {
  @override
  _OnboardingScreen3State createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3> {

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
      backgroundColor: HavkaColors.bone[100],
      body: Center(
        child: Text("2",
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen4 extends StatefulWidget {
  @override
  _OnboardingScreen4State createState() => _OnboardingScreen4State();
}

class _OnboardingScreen4State extends State<OnboardingScreen4> {

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
      backgroundColor: HavkaColors.bone[100],
      body: Center(
        child: Text("1",
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
