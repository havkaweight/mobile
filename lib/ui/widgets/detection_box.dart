import 'dart:math';

import 'package:flutter/material.dart';
import 'package:havka/constants/colors.dart';

class DetectionBoxPainter extends CustomPainter {
  final double width;
  final double height;
  final double lineWidth;
  final double lineRadius;

  const DetectionBoxPainter({
    required this.width,
    required this.height,
    required this.lineWidth,
    required this.lineRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dx = this.width;
    final dy = this.height;
    final lineWidth = this.lineWidth;
    final radius = this.lineRadius;

    final cornersPaint = Paint()
      ..strokeWidth = 5
      ..color = HavkaColors.green
      ..style = PaintingStyle.stroke;

    final bgPaint = Paint()..color = Colors.black.withOpacity(0.3);

    final center = Offset(size.width / 2, size.height / 2.5);

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

    box.addPolygon(
      [
        Offset(center.dx - dx, center.dy + dy - lineWidth),
        Offset(center.dx - dx, center.dy + dy - radius),
      ],
      false,
    );

    box.addPolygon(
      [
        Offset(center.dx - dx + radius, center.dy + dy),
        Offset(center.dx - dx + lineWidth, center.dy + dy),
      ],
      false,
    );

    box.addArc(
      Rect.fromCenter(
        center: Offset(center.dx - dx + radius, center.dy + dy - radius),
        width: radius * 2,
        height: radius * 2,
      ),
      pi * 0.5,
      pi * 0.5,
    );

    box.addPolygon(
      [
        Offset(center.dx + dx, center.dy + dy - lineWidth),
        Offset(center.dx + dx, center.dy + dy - radius),
      ],
      false,
    );

    box.addPolygon(
      [
        Offset(center.dx + dx - lineWidth, center.dy + dy),
        Offset(center.dx + dx - radius, center.dy + dy),
      ],
      false,
    );

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
  bool shouldRepaint(covariant DetectionBoxPainter oldDelegate) => false;
}

class DetectionBox extends StatelessWidget {
  final double width;
  final double height;
  final double lineWidth;
  final double lineRadius;

  const DetectionBox({
    required this.width,
    required this.height,
    this.lineWidth = 1.0,
    this.lineRadius = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: DetectionBoxPainter(
          width: width,
          height: height,
          lineWidth: lineWidth,
          lineRadius: lineRadius,
        ),
        child: Container(),
      )
    );
  }
}