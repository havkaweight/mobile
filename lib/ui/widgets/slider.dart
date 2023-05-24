import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class HavkaSliderPainter extends CustomPainter with ChangeNotifier {
  final double value;
  final double minValue;
  final double maxValue;
  HavkaSliderPainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    const double selectedCircleRadius = 8;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = HavkaColors.protein;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = HavkaColors.protein;

    final circleBorderPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height / 2.0)
        ..lineTo(size.width, size.height / 2.0),
      linePaint,
    );

    // for (int i = 0; i < 6; i++) {
    //   canvas.drawCircle(
    //     Offset(i * 20 / maxValue * size.width, size.height / 2.0),
    //     3,
    //     circlePaint,
    //   );
    // }

    canvas.drawCircle(
      Offset(value / maxValue * size.width, size.height / 2.0),
      selectedCircleRadius * 1.1,
      circleBorderPaint,
    );

    canvas.drawCircle(
      Offset(value / maxValue * size.width, size.height / 2.0),
      selectedCircleRadius,
      circlePaint,
    );

    final TextSpan textSpan = TextSpan(
      text: value.toStringAsFixed(1),
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
      Offset(value / maxValue * size.width,
              size.height / 2.0 - selectedCircleRadius) -
          Offset(textPainter.width / 2.0, textPainter.height),
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
  final double minValue;
  final double maxValue;
  final Function(double) onUpdate;
  const HavkaSlider({
    this.value = 0.0,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    required this.onUpdate,
  });

  @override
  _HavkaSliderState createState() => _HavkaSliderState();
}

class _HavkaSliderState extends State<HavkaSlider> {
  late double value;

  late bool _isSliderSelected;
  @override
  void initState() {
    super.initState();
    value = widget.value;
    _isSliderSelected = false;
  }

  @override
  void didUpdateWidget(covariant HavkaSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        if ((details.localPosition.dx /
                        context.size!.width *
                        (widget.maxValue - widget.minValue) -
                    value)
                .abs() <
            (widget.maxValue - widget.minValue) * 0.1) {
          _isSliderSelected = true;
        }
      },
      onHorizontalDragEnd: (details) {
        _isSliderSelected = false;
      },
      onHorizontalDragUpdate: (details) {
        if (_isSliderSelected) if (value >= widget.minValue &&
            value <= widget.maxValue) {
          setState(() {
            value += details.delta.dx /
                context.size!.width *
                (widget.maxValue - widget.minValue);
            widget.onUpdate(value);
          });
        } else if (value < widget.minValue) {
          setState(() {
            value = widget.minValue;
          });
        } else if (value > widget.maxValue) {
          setState(() {
            value = widget.maxValue;
          });
        }
      },
      child: CustomPaint(
        painter: HavkaSliderPainter(
          value: value,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
        ),
        child: Container(),
      ),
    );
  }
}
