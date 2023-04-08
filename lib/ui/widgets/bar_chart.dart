import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:health_tracker/model/data_items.dart';

class HavkaBarChart extends CustomPainter {
  final List<DataItem> data;
  HavkaBarChart(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double left = size.width * 0.2;
    final double maxValue = data.map((di) => di.value).reduce(max);
    final int valuesCount = data.length;
    final double barWidth = (size.width - 2 * left) / valuesCount;
    for (final di in data) {
      final height = di.value / maxValue * size.height / 3.0;
      final rect =
          Rect.fromLTWH(left, size.height / 1.5, barWidth * 0.9, -height);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawRect(rect, paint);
      left += barWidth;
    }
  }

  @override
  bool shouldRepaint(covariant HavkaBarChart oldDelegate) => true;
}
