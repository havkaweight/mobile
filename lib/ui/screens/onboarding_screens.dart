import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/data_items.dart';
import 'package:health_tracker/ui/widgets/bar_chart_timeline.dart';
import 'package:health_tracker/ui/widgets/donut_chart.dart';
import 'package:health_tracker/ui/widgets/line_chart.dart';

class OnboardingScreen1 extends StatefulWidget {
  @override
  _OnboardingScreen1State createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  late List<DataItem> data;
  late Timer _addData;

  @override
  void initState() {
    super.initState();
    // data = [
    //   DataItem(100, "Monday", Colors.amber[500]!),
    //   DataItem(200, "Tuesday", Colors.amber[800]!),
    //   DataItem(120, "Wednesday", Colors.amber[900]!),
    //   DataItem(210, "Thursday", Colors.yellow[300]!),
    //   DataItem(80, "Friday", Colors.yellow[500]!),
    //   DataItem(240, "Saturday", Colors.amber[200]!),
    //   DataItem(270, "Sunday", Colors.amber[400]!),
    // ];
    int n = 0;
    _addData = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (n > 3) {
        timer.cancel();
      }
      // setState(() {
      //   data.insert(
      //     0,
      //     DataItem(
      //       Random().nextInt(100) + 100,
      //       'label',
      //       Colors.amber[500]!,
      //     ),
      //   );
      // });
      n++;
    });
  }

  @override
  void dispose() {
    _addData.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HavkaColors.bone[200],
      body: Center(
        child: CustomPaint(
          painter: HavkaBarChart(data),
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
  late Timer _updateValues;
  late Timer _smoothAnimation;

  @override
  void initState() {
    super.initState();
    // data = [
    //   DataItem(0.2, "Protein", Colors.amber[50]!),
    //   DataItem(0.3, "Fat", Colors.amber[200]!),
    //   DataItem(0.5, "Carbs", Colors.amber[400]!),
    // ];
    int n = 0;
    _updateValues = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (n > 3) {
        timer.cancel();
        return;
      }
      const int milliseconds = 10;
      final double firstRandom = Random().nextDouble();
      final double secondRandom = (1 - firstRandom) * Random().nextDouble();
      final double last = 1 - firstRandom - secondRandom;
      _smoothAnimation = Timer.periodic(
          const Duration(milliseconds: milliseconds), (Timer timer) {
        final double prevFirstRandom = data[0].value;
        final double prevSecondRandom = data[1].value;
        final double prevLast = data[2].value;
        final double tempFirstRandom =
            (firstRandom - prevFirstRandom) * 1.0 / milliseconds;
        final double tempSecondRandom =
            (secondRandom - prevSecondRandom) * 1.0 / milliseconds;
        final double tempLast = (last - prevLast) * 1.0 / milliseconds;
        if ([
              firstRandom - prevFirstRandom,
              secondRandom - prevSecondRandom,
              last - prevLast
            ].reduce(max) <
            0.01) {
          timer.cancel();
          return;
        }
        // setState(() {
        //   data = [
        //     DataItem(
        //       prevFirstRandom + tempFirstRandom,
        //       "Protein",
        //       Colors.amber[50]!,
        //     ),
        //   ];
        //   data.add(
        //     DataItem(
        //       prevSecondRandom + tempSecondRandom,
        //       "Fat",
        //       Colors.amber[200]!,
        //     ),
        //   );
        //   data.add(
        //     DataItem(
        //       prevLast + tempLast,
        //       "Carbs",
        //       Colors.amber[400]!,
        //     ),
        //   );
        // });
      });
      n++;
    });
  }

  @override
  void dispose() {
    _updateValues.cancel();
    _smoothAnimation.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HavkaColors.bone[200],
      body: Center(
          // child: CustomPaint(
          //   painter: HavkaDonutChart(data),
          //   child: Container(),
          // ),
          ),
    );
  }
}

class OnboardingScreen3 extends StatefulWidget {
  @override
  _OnboardingScreen3State createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3> {
  late List<DataPoint> mockDataPoints;

  @override
  void initState() {
    super.initState();
    mockDataPoints = [DataPoint(0, 0)];
    for (int i = 0; i < 30; i++) {
      mockDataPoints.add(
        DataPoint(
          mockDataPoints.last.dx + 5,
          mockDataPoints.last.dy + (Random().nextDouble() * 2 - 1) * 10,
        ),
      );
    }
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
