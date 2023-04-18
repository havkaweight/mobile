import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class HavkaBarcode extends CustomPainter {
  final List<int> data = [20, 9, 16, 9, 4, 15, 18];

  @override
  void paint(Canvas canvas, Size size) {
    double left = 0.0;
    final int width = data.reduce((value, element) => value + element) +
        (data.length - 1) * 7;

    for (final di in data) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, di * size.width / width, size.height),
        const Radius.circular(1),
      );
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = HavkaColors.green;
      canvas.drawRRect(rect, paint);
      left += (di + 7) * size.width / width;
    }
  }

  @override
  bool shouldRepaint(covariant HavkaBarcode oldDelegate) => false;
}
