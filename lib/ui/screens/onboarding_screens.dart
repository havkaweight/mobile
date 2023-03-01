

import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:flutter/src/painting/text_style.dart' as textStyle;
import 'package:health_tracker/ui/widgets/donut_chart.dart';

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
      DataPoint(0, 0)
    ];

    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if(mockDataPoints.last.dx > 200) {
        timer.cancel();
        return;
      }
      setState(() {
        mockDataPoints.add(DataPoint(mockDataPoints.last.dx+5, mockDataPoints.last.dy + (Random().nextDouble()*2-1)*10));
      });
    });
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
          child: CustomPaint(
            painter: HavkaLineChart(mockDataPoints),
            child: Container(),
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
  late List<DataItem> data;

  @override
  void initState() {
    super.initState();
    data = [
      DataItem(0.2, "Protein", Colors.amber[50]!),
      DataItem(0.3, "Fat", Colors.amber[200]!),
      DataItem(0.5, "Carbs", Colors.amber[400]!),
    ];
    int n = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if(n > 3) {
        timer.cancel();
        return;
      }
      const int milliseconds = 10;
      final double firstRandom = Random().nextDouble();
      final double secondRandom = (1 - firstRandom) * Random().nextDouble();
      final double last = 1 - firstRandom - secondRandom;
      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        final double prevFirstRandom = data[0].value;
        final double prevSecondRandom = data[1].value;
        final double prevLast = data[2].value;
        final double tempFirstRandom = (firstRandom - prevFirstRandom) * 1.0 / milliseconds;
        final double tempSecondRandom = (secondRandom - prevSecondRandom) * 1.0 / milliseconds;
        final double tempLast = (last - prevLast) * 1.0 / milliseconds;
        if([firstRandom-prevFirstRandom, secondRandom-prevSecondRandom, last-prevLast].reduce(max) < 0.01) {
          timer.cancel();
          return;
        }
        setState(() {
          data = [DataItem(prevFirstRandom + tempFirstRandom, "Protein", Colors.amber[50]!)];
          data.add(DataItem(prevSecondRandom + tempSecondRandom, "Fat", Colors.amber[200]!));
          data.add(DataItem(prevLast + tempLast, "Carbs", Colors.amber[400]!));
        });
      });
      n ++;
    });
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
        child: CustomPaint(
          painter: HavkaDonutChart(data),
          child: Container(),
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
