import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class HavkaSliderPainter extends CustomPainter with ChangeNotifier {
  final double value;
  HavkaSliderPainter({
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = HavkaColors.protein;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = HavkaColors.protein;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height / 2.0)
        ..lineTo(size.width, size.height / 2.0),
      linePaint,
    );

    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(i * 20 / 100 * size.width, size.height / 2.0),
        3,
        circlePaint,
      );
    }

    canvas.drawCircle(
      Offset(value / 100 * size.width, size.height / 2.0),
      8,
      circlePaint,
    );

    final TextSpan textSpan = TextSpan(
      text: '$value',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
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
      Offset(value / 100 * size.width, size.height / 2.0 * 0.87) -
          Offset(textPainter.width / 2.0, textPainter.height / 2.0),
    );
  }

  @override
  bool shouldRepaint(covariant HavkaSliderPainter oldDelegate) => true;

  // @override
  // bool hitTest(Offset position) {
  //   }
}

class HavkaSlider extends StatefulWidget {
  final double value;
  const HavkaSlider({
    this.value = 0,
  });

  @override
  _HavkaSliderState createState() => _HavkaSliderState();
}

class _HavkaSliderState extends State<HavkaSlider> {
  late double value;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void didUpdateWidget(covariant HavkaSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HavkaSliderPainter(
        value: value,
      ),
      child: Container(),
    );
  }
}
