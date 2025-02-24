import 'package:flutter/material.dart';

class CustomHumanFigure extends StatelessWidget {
  final double bustSize;
  final double waistSize;
  final double hipSize;

  CustomHumanFigure({
    this.bustSize = 90,
    this.waistSize = 60,
    this.hipSize = 90,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HumanFigurePainter(bustSize, waistSize, hipSize),
      child: Container(),
    );
  }
}

class HumanFigurePainter extends CustomPainter {
  final double bustSize;
  final double waistSize;
  final double hipSize;

  HumanFigurePainter(this.bustSize, this.waistSize, this.hipSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw the torso
    double torsoHeight = 100;
    Rect torsoRect = Rect.fromPoints(
      Offset(size.width / 2 - waistSize / 2, size.height / 2 - torsoHeight),
      Offset(size.width / 2 + waistSize / 2, size.height / 2),
    );
    canvas.drawRect(torsoRect, paint);

    // Draw the bust
    double bustHeight = torsoHeight * 0.4;
    canvas.drawArc(
      Rect.fromCircle(center: torsoRect.topCenter, radius: bustSize / 2),
      0,
      3.14, // 180 degrees
      false,
      paint,
    );

    // Draw the hips
    double hipHeight = torsoHeight * 0.3;
    Rect hipRect = Rect.fromPoints(
      Offset(size.width / 2 - hipSize / 2, size.height / 2),
      Offset(size.width / 2 + hipSize / 2, size.height / 2 + hipHeight),
    );
    canvas.drawRect(hipRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}