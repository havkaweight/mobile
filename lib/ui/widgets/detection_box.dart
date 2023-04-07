import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

import '../../model/data_items.dart';

class DetectionBox extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornersPaint = Paint()
      ..strokeWidth = 5
      ..color = HavkaColors.green
      ..style = PaintingStyle.stroke;

    final bgPaint = Paint()..color = Colors.black.withOpacity(0.5);

    final center = Offset(size.width / 2, size.height / 3);
    final lineWidth = size.width / 12;
    final radius = lineWidth / 3;
    final dx = size.width / 3;
    final dy = size.height / 7;

    final box = Path();
    box.addPolygon(
      [
        Offset(center.dx - dx, center.dy - dy + lineWidth),
        Offset(center.dx - dx, center.dy - dy + radius),
      ],
      false,
    );

    box.addPolygon(
      [
        Offset(center.dx - dx + lineWidth, center.dy - dy),
        Offset(center.dx - dx + radius, center.dy - dy),
      ],
      false,
    );

    box.addArc(
      Rect.fromCenter(
        center: Offset(center.dx - dx + radius, center.dy - dy + radius),
        width: radius * 2,
        height: radius * 2,
      ),
      pi,
      pi * 0.5,
    );

    box.addPolygon(
      [
        Offset(center.dx + dx, center.dy - dy + lineWidth),
        Offset(center.dx + dx, center.dy - dy + radius),
      ],
      false,
    );

    box.addPolygon(
      [
        Offset(center.dx + dx - lineWidth, center.dy - dy),
        Offset(center.dx + dx - radius, center.dy - dy),
      ],
      false,
    );

    box.addArc(
      Rect.fromCenter(
        center: Offset(center.dx + dx - radius, center.dy - dy + radius),
        width: radius * 2,
        height: radius * 2,
      ),
      pi * 1.5,
      pi * 0.5,
    );

    box.addPolygon([
      Offset(center.dx - dx, center.dy + dy - lineWidth),
      Offset(center.dx - dx, center.dy + dy - radius),
    ], false);

    box.addPolygon([
      Offset(center.dx - dx + radius, center.dy + dy),
      Offset(center.dx - dx + lineWidth, center.dy + dy),
    ], false);

    box.addArc(
      Rect.fromCenter(
        center: Offset(center.dx - dx + radius, center.dy + dy - radius),
        width: radius * 2,
        height: radius * 2,
      ),
      pi * 0.5,
      pi * 0.5,
    );

    box.addPolygon([
      Offset(center.dx + dx, center.dy + dy - lineWidth),
      Offset(center.dx + dx, center.dy + dy - radius),
    ], false);

    box.addPolygon([
      Offset(center.dx + dx - lineWidth, center.dy + dy),
      Offset(center.dx + dx - radius, center.dy + dy),
    ], false);

    box.addArc(
      Rect.fromCenter(
        center: Offset(center.dx + dx - radius, center.dy + dy - radius),
        width: radius * 2,
        height: radius * 2,
      ),
      0,
      pi * 0.5,
    );

    final bg = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromCenter(center: center, width: dx * 2, height: dy * 2))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(bg, bgPaint);
    canvas.drawPath(box, cornersPaint);
  }

  @override
  bool shouldRepaint(covariant DetectionBox oldDelegate) => true;
}
