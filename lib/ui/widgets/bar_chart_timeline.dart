import 'dart:math';

import 'package:flutter/material.dart';

import 'package:health_tracker/model/data_items.dart';

class HavkaBarChart extends CustomPainter {
  final List<DataItem> data;
  HavkaBarChart(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double left = 0.0;
    final double maxValue = data.map((di) => di.value).reduce(max);
    final int valuesCount = data.length;
    final double barWidth = size.width / valuesCount;
    for (final di in data) {
      final height = di.value / maxValue * size.height / 3.0;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height / 1.5, barWidth * 0.9, -height),
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
        textDirection: TextDirection.ltr,
      );
      datePainter.layout();
      datePainter.paint(
        canvas,
        Offset(left + barWidth * 0.9 / 2.0, size.height / 1.4) +
            Offset(-datePainter.width / 2.0, -datePainter.height / 2.0),
      );

      final TextSpan valueSpan = TextSpan(
        text: di.value.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
      final TextPainter valuePainter = TextPainter(
        text: valueSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(left + barWidth * 0.9 / 2.0, -height + size.height / 1.6) +
            Offset(-valuePainter.width / 2.0, -valuePainter.height / 2.0),
      );
      left += barWidth;
    }
  }

  @override
  bool shouldRepaint(covariant HavkaBarChart oldDelegate) => true;
}
