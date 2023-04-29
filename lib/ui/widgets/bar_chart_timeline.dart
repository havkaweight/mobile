import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';

import 'package:health_tracker/model/data_items.dart';
import 'package:health_tracker/model/user_consumption_item.dart';
import 'package:health_tracker/utils/utils.dart';
import 'package:intl/intl.dart';

class HavkaBarChartPainter extends CustomPainter {
  final List<DataItem> data;
  HavkaBarChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    double left = 0.0;
    final double maxValue = data.map((di) => di.value).reduce(max);
    final int valuesCount = data.length;
    final double barWidth = size.width / valuesCount;
    for (final di in data) {
      final height = di.value / maxValue * size.height * 0.9;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height * 0.9, barWidth * 0.9, -height),
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
      );
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawRRect(rect, paint);

      final TextSpan dateSpan = TextSpan(
        text: di.label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      );
      final TextPainter datePainter = TextPainter(
        text: dateSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );
      datePainter.layout();
      datePainter.paint(
        canvas,
        Offset(left + barWidth * 0.9 / 2.0, size.height * 0.98) +
            Offset(-datePainter.width / 2.0, -datePainter.height / 2.0),
      );

      final TextSpan valueSpan = TextSpan(
        text: di.value.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
      final TextPainter valuePainter = TextPainter(
        text: valueSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(
              left + barWidth * 0.9 / 2.0,
              -(di.value / maxValue * size.height * 0.9) + size.height * 0.84,
            ) +
            Offset(-valuePainter.width / 2.0, -valuePainter.height / 2.0),
      );
      left += barWidth;
    }
  }

  @override
  bool shouldRepaint(covariant HavkaBarChartPainter oldDelegate) => true;
}

class HavkaBarChart extends StatefulWidget {
  final List<UserConsumptionItem> initialData;
  const HavkaBarChart({required this.initialData});

  @override
  _HavkaBarChartState createState() => _HavkaBarChartState();
}

class _HavkaBarChartState extends State<HavkaBarChart> {
  late List<DataItem> weightsData;
  late List<DateTime> datesPeriod;

  @override
  void initState() {
    super.initState();
    final DateTime currentDate = DateTime.now();
    final DateTime maxDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    final DateTime minDate = maxDate.subtract(const Duration(days: 6));
    datesPeriod = getDaysInBetween(minDate, maxDate);
    weightsData = [];
    for (final DateTime date in datesPeriod) {
      weightsData.add(
        DataItem(
          widget.initialData.fold(0, (previousValue, element) {
            if ((element.consumedAt ?? element.createdAt)!
                        .difference(date)
                        .inDays ==
                    0 &&
                (element.consumedAt ?? element.createdAt)!.isAfter(date)) {
              return previousValue += element.amount!.value;
            }
            return previousValue;
          }),
          DateFormat('MMM dd').format(date),
          Colors.amber[500]!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomPaint(
        painter: HavkaBarChartPainter(data: weightsData),
        child: Container(
          height: 40,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HavkaBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      final List<DataItem> oldWeightsData = [];
      final DateTime currentDate = DateTime.now();
      final DateTime maxDate =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      final DateTime minDate = maxDate.subtract(const Duration(days: 6));
      datesPeriod = getDaysInBetween(minDate, maxDate);
      for (final DateTime date in datesPeriod) {
        oldWeightsData.add(
          DataItem(
            oldWidget.initialData.fold(0, (previousValue, element) {
              if ((element.consumedAt ?? element.createdAt)!
                          .difference(date)
                          .inDays ==
                      0 &&
                  (element.consumedAt ?? element.createdAt)!.isAfter(date)) {
                return previousValue += element.amount!.value;
              }
              return previousValue;
            }),
            DateFormat('MMM dd').format(date),
            Colors.amber[500]!,
          ),
        );
      }

      final List<DataItem> newWeightsData = [];
      for (final DateTime date in datesPeriod) {
        newWeightsData.add(
          DataItem(
            widget.initialData.fold(0, (previousValue, element) {
              if ((element.consumedAt ?? element.createdAt)!
                          .difference(date)
                          .inDays ==
                      0 &&
                  (element.consumedAt ?? element.createdAt)!.isAfter(date)) {
                return previousValue += element.amount!.value;
              }
              return previousValue;
            }),
            DateFormat('MMM dd').format(date),
            Colors.amber[500]!,
          ),
        );
      }
      final List<double> weightsDiff = [
        for (int i = 0; i < oldWeightsData.length; i++)
          newWeightsData[i].value - oldWeightsData[i].value
      ];
      final double maxDiff = weightsDiff
          .reduce((value, element) => max(value.abs(), element.abs()));
      final List<DataItem> tempWeightsData = oldWeightsData;
      const int milliseconds = 40;
      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        if (maxDiff < 0.1) {
          timer.cancel();
        } else {
          setState(() {
            for (int i = 0; i < tempWeightsData.length; i++) {
              tempWeightsData[i].value = tempWeightsData[i].value +
                  (newWeightsData[i].value - tempWeightsData[i].value) /
                      milliseconds *
                      10;
            }
            weightsData = tempWeightsData;
          });
        }
      });
    }
  }
}
