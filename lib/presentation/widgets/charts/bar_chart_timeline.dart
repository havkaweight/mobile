import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../data/models/data_item.dart';
import '/core/constants/utils.dart';

class HavkaBarChartPainter extends CustomPainter {
  final List<DataItem> data;
  final DataItem? selectedBar;
  final num? targetValue;
  final Function(DataItem)? onSelectedBar;

  HavkaBarChartPainter({
    required this.data,
    this.selectedBar,
    this.targetValue,
    this.onSelectedBar,
  });

  late Size _size;

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    double left = 0.0;
    num maxValue = data.map((di) => di.value).reduce(max);
    final int valuesCount = data.length;
    final double barWidth = size.width / valuesCount;

    if (targetValue != null) {
      maxValue = max(maxValue, targetValue!);
    }

    final labelHeightSpan = TextSpan(
      text: "Height",
      style: TextStyle(
        color: Colors.black,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );

    final TextPainter labelHeightPainter = TextPainter(
      text: labelHeightSpan,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    labelHeightPainter.layout();

    final normalizedHeight =
        maxValue / (size.height - 2.5 * labelHeightPainter.height);

    for (final di in data) {

      // if (di == selectedBar) {
      //   final areaRect = RRect.fromRectAndRadius(
      //     Rect.fromLTWH(
      //       left,
      //       0,
      //       barWidth,
      //       _size.height,
      //     ),
      //     Radius.circular(10),
      //   );
      //   final areaPaint = Paint()
      //     ..style = PaintingStyle.fill
      //     ..color = Colors.black.withOpacity(0.05);
      //   canvas.drawRRect(areaRect, areaPaint);
      // }

      final TextPainter datePainter = TextPainter(
        text: TextSpan(
          text: di.label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: di == selectedBar ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );

      datePainter.layout();
      datePainter.paint(
          canvas,
          Offset(
            left + barWidth * 0.05 + barWidth * 0.9 / 2.0 - datePainter.width / 2.0,
            size.height - datePainter.height,
          ));

      final barHeight = di.value < 1.0 ? 1.0 : di.value / normalizedHeight;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          left + barWidth * 0.05,
          size.height - 1.5 * datePainter.height,
          barWidth * 0.9,
          -barHeight,
        ),
        topLeft: Radius.circular(5.0),
        topRight: Radius.circular(5.0),
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color.withValues(alpha: di == selectedBar ? 1.0 : 0.6);
      canvas.drawRRect(rect, paint);

      final TextPainter valuePainter = TextPainter(
        text: TextSpan(
          text: di.value.toStringAsFixed(0),
          style: TextStyle(
            color: Colors.black,
            fontWeight: di == selectedBar ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );

      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(
          left + barWidth * 0.05 + barWidth * 0.9 / 2.0 - valuePainter.width / 2.0,
          size.height - 1.5 * datePainter.height - barHeight - 1.2 * valuePainter.height,
        )
      );
      left += barWidth;
    }

    if (targetValue != null) {
      final dashedLinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.grey;

      final TextSpan dashedLineLabelSpan = TextSpan(
        text: "Daily Intake - ",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      );

      final TextPainter dashedLineLabelPainter = TextPainter(
        text: dashedLineLabelSpan,
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr,
      );

      dashedLineLabelPainter.layout();
      dashedLineLabelPainter.paint(
        canvas,
        Offset(
            0,
            size.height - 1.5 * labelHeightPainter.height - targetValue! / normalizedHeight - 1.2 * dashedLineLabelPainter.height,
        ),
      );

      final TextSpan dashedLineValueSpan = TextSpan(
        text: "${Utils().formatNumber(targetValue)} kcal",
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      );

      final TextPainter dashedLineValuePainter = TextPainter(
        text: dashedLineValueSpan,
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr,
      );

      dashedLineValuePainter.layout();
      dashedLineValuePainter.paint(
        canvas,
        Offset(
          dashedLineLabelPainter.width,
          size.height - 1.5 * labelHeightPainter.height - targetValue! / normalizedHeight - 1.2 * dashedLineValuePainter.height,
        ),
      );

      double dashedLeft = 0;
      for (int i = 0; i < 20; i++) {
        canvas.drawLine(
          Offset(
            dashedLeft,
            size.height - 1.5 * labelHeightPainter.height - targetValue! / normalizedHeight,
          ),
          Offset(
            dashedLeft + size.width / 20 * 0.7,
            size.height - 1.5 * labelHeightPainter.height - targetValue! / normalizedHeight,
          ),
          dashedLinePaint,
        );
        dashedLeft += size.width / 20;
      }
    }

  }

  @override
  bool hitTest(Offset position) {
    double left = 0.0;
    final int valuesCount = data.length;
    final double barWidth = _size.width / valuesCount;
    for(final di in data) {
      final rect = Rect.fromLTWH(
        left,
        0,
        barWidth * 0.9,
        _size.height,
      );
      left += barWidth;
      if(rect.contains(position)) {
        if(onSelectedBar != null) {
          onSelectedBar!(di);
        }
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(covariant HavkaBarChartPainter oldDelegate) => true;
}

class HavkaBarChart extends StatefulWidget {
  final List<DataItem> initialData;
  final DataItem? selectedBar;
  final double? targetValue;
  final Function(DataItem)? onSelectedBar;

  const HavkaBarChart({
    required this.initialData,
    this.selectedBar,
    this.targetValue,
    this.onSelectedBar,
  });

  @override
  _HavkaBarChartState createState() => _HavkaBarChartState();
}

class _HavkaBarChartState extends State<HavkaBarChart> {
  late List<DataItem> data;

  @override
  void initState() {
    super.initState();
    data = widget.initialData;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomPaint(
        painter: HavkaBarChartPainter(
          data: data,
          selectedBar: widget.selectedBar,
          targetValue: widget.targetValue,
          onSelectedBar: (di) => widget.onSelectedBar!(di),
        ),
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
      final List<DataItem> oldWeightsData = oldWidget.initialData;
      final List<DataItem> newWeightsData = widget.initialData;

      final List<double> weightsDiff = [
        for (int i = 0; i < oldWeightsData.length; i++)
          newWeightsData[i].value - oldWeightsData[i].value
      ];
      // final int maxDiff = weightsDiff
      //     .reduce((value, element) => max(value.abs(), element.abs()));
      final List<DataItem> tempWeightsData = oldWeightsData;
      const int milliseconds = 30;
      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        setState(() {
          for (int i = 0; i < tempWeightsData.length; i++) {
            if ((newWeightsData.fold(
                            0.0, (sum, element) => sum + element.value) -
                        tempWeightsData.fold(
                            0.0, (sum, element) => sum + element.value))
                    .abs() <
                0.01) {
              tempWeightsData[i].value = newWeightsData[i].value;
              timer.cancel();
            }
            tempWeightsData[i].value = tempWeightsData[i].value +
                (newWeightsData[i].value - tempWeightsData[i].value) /
                    milliseconds *
                    10;
          }
          data = tempWeightsData;
        });
      });
    }
  }
}
