import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:health_tracker/model/data_items.dart';

class HavkaStackBarChart extends CustomPainter {
  final List<DataItem> data;
  HavkaStackBarChart({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    double left = 0.0;
    final double valuesSum = data
        .map((di) => di.value)
        .fold(0.0, (previousValue, element) => previousValue + element);
    for (final di in data) {
      final double barWidth = di.value / valuesSum * size.width;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, 0, barWidth, size.height),
        topLeft: di == data.first ? const Radius.circular(10) : Radius.zero,
        bottomLeft: di == data.first ? const Radius.circular(10) : Radius.zero,
        topRight: di == data.last ? const Radius.circular(10) : Radius.zero,
        bottomRight: di == data.last ? const Radius.circular(10) : Radius.zero,
      );
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawRRect(rect, paint);
      left += barWidth;
    }
  }

  @override
  bool shouldRepaint(covariant HavkaStackBarChart oldDelegate) => true;
}
