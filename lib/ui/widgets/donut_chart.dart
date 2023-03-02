import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/data_items.dart';


class HavkaDonutChart extends CustomPainter {
  final List<DataItem> data;
  HavkaDonutChart(this.data);

  final linePaint = Paint()
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke
    ..color = Colors.white;

  final midPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    double startAngle = 0.0;
    final radius = size.width * 0.8;
    final rect = Rect.fromCenter(center: center, width: radius, height: radius);
    for(final di in data) {
      final sweepAngle = di.value * 2.0 * pi;
      final dx = radius / 2.0 * cos(startAngle);
      final dy = radius / 2.0 * sin(startAngle);
      final p2 = center + Offset(dx, dy);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      canvas.drawLine(center, p2, linePaint);
      startAngle += sweepAngle;
    }
    canvas.drawCircle(center, radius * 0.3, midPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
