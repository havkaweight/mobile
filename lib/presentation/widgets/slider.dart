import 'dart:async';

import 'package:flutter/material.dart';
import '/core/constants/colors.dart';

class HavkaSliderPainter extends CustomPainter with ChangeNotifier {
  final double value;
  final double minValue;
  final double maxValue;
  final double radius;
  final Color lineColor;
  final Color pointColor;

  HavkaSliderPainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.radius,
    this.lineColor = Colors.black,
    this.pointColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = lineColor;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = pointColor;

    final circleBorderPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = HavkaColors.cream;

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
      radius * 1.2,
      circleBorderPaint,
    );

    canvas.drawCircle(
      Offset(value / maxValue * size.width, size.height / 2.0),
      radius,
      circlePaint,
    );

    final TextSpan textSpan = TextSpan(
      text: value.toStringAsFixed(1),
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: radius + 6,
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
      Offset(value / maxValue * size.width, size.height / 2.0 - radius * 1.2) -
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
  final double shift;
  final Function(double) onUpdate;
  final Color lineColor;
  final Color pointColor;
  final double minRadius;
  final double maxRadius;

  const HavkaSlider({
    this.value = 0.0,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.shift = 0.1,
    this.lineColor = Colors.black,
    this.pointColor = Colors.black,
    required this.onUpdate,
    this.minRadius = 8,
    this.maxRadius = 12,
  });

  @override
  _HavkaSliderState createState() => _HavkaSliderState();
}

class _HavkaSliderState extends State<HavkaSlider> {
  late double value;
  late double radius;

  late bool _isSliderSelected;

  @override
  void initState() {
    super.initState();
    value = widget.value;
    radius = widget.minRadius;
    _isSliderSelected = false;
  }

  @override
  void didUpdateWidget(covariant HavkaSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if ((details.localPosition.dx /
                        context.size!.width *
                        (widget.maxValue - widget.minValue) -
                    value)
                .abs() <
            (widget.maxValue - widget.minValue) * 0.1) {
          Timer.periodic(const Duration(milliseconds: 10), (timer) {
            if ((radius - widget.maxRadius).abs() > 0.1) {
              radius += (widget.maxRadius - widget.minRadius) / 10;
            } else {
              radius = widget.maxRadius;
              timer.cancel();
            }
            setState(() {});
          });
          _isSliderSelected = true;
        }
      },
      onTapUp: (details) {
        if ((details.localPosition.dx /
            context.size!.width *
            (widget.maxValue - widget.minValue) -
            value)
            .abs() <
            (widget.maxValue - widget.minValue) * 0.1) {
          Timer.periodic(const Duration(milliseconds: 10), (timer) {
            if ((radius - widget.minRadius).abs() > 0.1) {
              radius -= (widget.maxRadius - widget.minRadius) / 10;
            } else {
              radius = widget.minRadius;
              timer.cancel();
            }
            setState(() {});
          });
          _isSliderSelected = false;
        }
      },
      onHorizontalDragEnd: (details) {
        Timer.periodic(const Duration(milliseconds: 10), (timer) {
          if (radius > widget.minRadius) {
            setState(() {
              radius -= (widget.maxRadius - widget.minRadius) / 10;
            });
          } else {
            timer.cancel();
          }
        });
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
          radius: radius,
          lineColor: widget.lineColor,
          pointColor: widget.pointColor
        ),
        child: Container(),
      ),
    );
  }
}
