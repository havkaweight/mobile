import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:health_tracker/constants/colors.dart';

import 'package:health_tracker/model/data_items.dart';

class HavkaDonutChart extends CustomPainter {
  final List<PFCDataItem> data;
  final String? centerText;
  HavkaDonutChart({
    required this.data,
    this.centerText,
  });

  final linePaint = Paint()
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke
    ..color = Colors.white;

  final midPaint = Paint()
    ..color = HavkaColors.cream
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    double startAngle = 0.0;
    final radius = size.width;
    final rect = Rect.fromCenter(center: center, width: radius, height: radius);
    final totalSum = data.map((di) => di.value).reduce((a, b) => a + b);
    for (final di in data) {
      final sweepAngle = di.value / totalSum * 2.0 * pi;
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

    final TextSpan textSpan = TextSpan(
      text: centerText,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: size.width / 5,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center + Offset(-textPainter.width / 2.0, -textPainter.height / 2.0),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
