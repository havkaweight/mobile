import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataPoint {
  final double dx;
  final double dy;

  DataPoint({
    required this.dx,
    required this.dy,
  });
}

class HavkaLineChart extends CustomPainter {
  List<DataPoint> mockDataPoints;

  HavkaLineChart({
    required this.mockDataPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

    final axis = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height);

    final data = Path()..moveTo(-200, 400);

    for(final dataPoint in mockDataPoints) {
      data.lineTo(-200+dataPoint.dx, 400+dataPoint.dy);
    }

    canvas.drawPath(data, axisPaint);
    // canvas.drawPath(axis, axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
