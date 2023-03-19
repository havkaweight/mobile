import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/data_items.dart';

class HavkaLineChart extends CustomPainter {
  List<DataPoint> mockDataPoints;

  HavkaLineChart(this.mockDataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final horizontalAxie = Path()
      ..moveTo(size.width * 0.2, size.height / 2.0)
      ..lineTo(size.width * 0.8, size.height / 2.0);

    final data = Path()..moveTo(size.width * 0.2, size.height / 2.0);
    final totalWidth = mockDataPoints.last.dx - mockDataPoints.first.dx;
    final normalizedWidth = totalWidth / (size.width * 0.6);
    for(final dataPoint in mockDataPoints) {
      data.lineTo(size.width * 0.2 + dataPoint.dx/normalizedWidth, size.height / 2.0 + dataPoint.dy);
      final center = Offset(size.width * 0.2 + dataPoint.dx/normalizedWidth, size.height / 2.0 + dataPoint.dy);
      canvas.drawCircle(center, 3, circlePaint);
    }

    canvas.drawPath(data, linePaint);
    canvas.drawPath(horizontalAxie, axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
