import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataPoint {
  final double dx;
  final double dy;

  DataPoint(this.dx, this.dy);
}

class HavkaLineChart extends CustomPainter {
  List<DataPoint> mockDataPoints;

  HavkaLineChart(this.mockDataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

    final axis = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height);

    final data = Path()..moveTo(0, size.height / 2.0);

    for(final dataPoint in mockDataPoints) {
      data.lineTo(dataPoint.dx, size.height / 2.0 + dataPoint.dy);
    }

    canvas.drawPath(data, axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
