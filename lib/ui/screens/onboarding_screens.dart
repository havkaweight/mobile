

import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:flutter/src/painting/text_style.dart' as textStyle;

import '../widgets/line_chart.dart';

class OnboardingScreen1 extends StatefulWidget {
  @override
  _OnboardingScreen1State createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  late List<DataPoint> mockDataPoints;

  @override
  void initState() {
    super.initState();
    mockDataPoints = [
      DataPoint(dx: 0, dy: 0)
    ];

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        mockDataPoints.add(DataPoint(dx: mockDataPoints.last.dx+5, dy: mockDataPoints.last.dy + (Random().nextDouble()*2-1)*10));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HavkaColors.bone[100],
      body: Center(
          child: Column(
            children: [
              CustomPaint(
                painter: HavkaLineChart(mockDataPoints: mockDataPoints),
              ),
            ],
          ),
      ),
    );
  }
}

class OnboardingScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HavkaColors.bone[200],
      body: const Center(
        child: Text(
          "Second Tip",
          style: textStyle.TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HavkaColors.bone[100],
      body: const Center(
        child: Text(
          "Third Tip",
          style: textStyle.TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
