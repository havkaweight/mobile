import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HavkaProteinIcon extends CustomPainter {
  final Color color;
  HavkaProteinIcon({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    double left = 0;
    double top = size.height * 5 / 6;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = color;

    for (int i = 0; i < 3; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, size.width / 3, size.height / 6),
        const Radius.circular(1),
      );
      canvas.drawRRect(rect, fillPaint);
      if (i < 2) {
        final path = Path()
          ..moveTo((left + size.width / 3) * 0.95, top * 1.01)
          ..lineTo(
            (left + size.width / 8) * 1.05,
            (top - size.height / 3) * 1.05,
          )
          ..moveTo(
            (left + size.width / 3) * 0.95,
            (top + size.height / 6) * 0.99,
          )
          ..lineTo(
            (left + size.width / 8) * 1.05,
            (top + size.height / 6 - size.height / 3) * 0.95,
          );
        canvas.drawPath(path, strokePaint);
      }
      left += size.width / 8;
      top -= size.height / 3;
    }
  }

  @override
  bool shouldRepaint(covariant HavkaProteinIcon oldDelegate) => false;
}
