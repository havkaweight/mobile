import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/data_items.dart';


class HavkaBarChart extends CustomPainter {
  final List<DataItem> data;
  HavkaBarChart(this.data);

  final linePaint = Paint()
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke
    ..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    double left = size.width*0.2;
    for(final di in data) {
      final height = di.value * size.height/2.0;
      final rect = Rect.fromLTWH(left, size.height/1.5, size.width*0.2, -height);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawRect(rect, paint);
      left += size.width*0.22;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
