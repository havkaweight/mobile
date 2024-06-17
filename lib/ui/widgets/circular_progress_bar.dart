import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:havka/constants/colors.dart';

class HavkaCircularProgressBarPainter extends CustomPainter {
  final double value;
  HavkaCircularProgressBarPainter({
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2.0,
      size.height / 2.0,
    );
    const double startAngle = -pi / 2;
    double maxValue = 1;
    const double maxRadiusFactor = 1.0;
    const double minRadiusFactor = 0.87;
    final double radius = size.width / 2.0;
    final double delta =
        (minRadiusFactor + maxRadiusFactor) / 13.5 * (value > 0.5 ? 1 : 0);
    final sweepAngle = value / maxValue * 2.0 * pi;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = HavkaColors.green;
    final paintBg = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(100, 220, 220, 220);
    canvas.drawPath(
        Path()
          ..addArc(
            Rect.fromCenter(
              center: center,
              width: radius * 2.0 * maxRadiusFactor,
              height: radius * 2.0 * maxRadiusFactor,
            ),
            startAngle,
            2.0 * pi,
          )
          ..addArc(
            Rect.fromCenter(
              center: center,
              width: radius * 2.0 * minRadiusFactor,
              height: radius * 2.0 * minRadiusFactor,
            ),
            startAngle,
            2.0 * pi,
          )
          ..fillType = PathFillType.evenOdd,
        paintBg);
    canvas.drawPath(
      Path()
        ..addArc(
          Rect.fromCenter(
            center: center,
            width: radius * 2.0 * maxRadiusFactor,
            height: radius * 2.0 * maxRadiusFactor,
          ),
          startAngle,
          sweepAngle,
        )
        ..quadraticBezierTo(
          (center +
                  Offset(
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        cos(startAngle + sweepAngle + delta),
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        sin(startAngle + sweepAngle + delta),
                  ))
              .dx,
          (center +
                  Offset(
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        cos(startAngle + sweepAngle + delta),
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        sin(startAngle + sweepAngle + delta),
                  ))
              .dy,
          (center +
                  Offset(
                    radius * minRadiusFactor * cos(startAngle + sweepAngle),
                    radius * minRadiusFactor * sin(startAngle + sweepAngle),
                  ))
              .dx,
          (center +
                  Offset(
                    radius * minRadiusFactor * cos(startAngle + sweepAngle),
                    radius * minRadiusFactor * sin(startAngle + sweepAngle),
                  ))
              .dy,
        )
        ..addArc(
          Rect.fromCenter(
            center: center,
            width: radius * 2.0 * minRadiusFactor,
            height: radius * 2.0 * minRadiusFactor,
          ),
          startAngle + sweepAngle,
          -sweepAngle,
        )
        ..quadraticBezierTo(
          (center +
                  Offset(
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        cos(startAngle - delta),
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        sin(startAngle - delta),
                  ))
              .dx,
          (center +
                  Offset(
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        cos(startAngle - delta),
                    radius *
                        (minRadiusFactor + maxRadiusFactor) /
                        2 *
                        sin(startAngle - delta),
                  ))
              .dy,
          (center +
                  Offset(
                    radius * maxRadiusFactor * cos(startAngle),
                    radius * maxRadiusFactor * sin(startAngle),
                  ))
              .dx,
          (center +
                  Offset(
                    radius * maxRadiusFactor * cos(startAngle),
                    radius * maxRadiusFactor * sin(startAngle),
                  ))
              .dy,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// New Circular progress bar
class HavkaCircularProgressBar extends StatefulWidget {
  final double value;
  const HavkaCircularProgressBar({
    super.key,
    this.value = 0,
  });

  @override
  _HavkaCircularProgressBar createState() => _HavkaCircularProgressBar();
}

class _HavkaCircularProgressBar extends State<HavkaCircularProgressBar> {
  late double value;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HavkaCircularProgressBarPainter(
        value: value,
      ),
      child: Container(),
    );
  }

  @override
  void didUpdateWidget(covariant HavkaCircularProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      const int milliseconds = 40;
      double tempValue = oldWidget.value;
      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        if ((widget.value - tempValue).abs() < 0.01) {
          timer.cancel();
        } else {
          tempValue += (widget.value - tempValue) / milliseconds * 10;
          setState(() {
            value = tempValue;
          });
        }
      });
    }
  }
}

/// Old Circular progress bar
class CircularProgressBar extends StatefulWidget {
  final double value;

  const CircularProgressBar({
    super.key,
    required this.value,
  });
  @override
  State<CircularProgressBar> createState() => _CircularProgressBar();
}

class _CircularProgressBar extends State<CircularProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late final Color color;
  @override
  void initState() {
    if (widget.value > 0.8) {
      color = Colors.green;
    } else if (widget.value > 0.5) {
      color = Colors.amber;
    } else {
      color = Colors.red;
    }
    controller = AnimationController(
      value: 0,
      upperBound: widget.value.abs(),
      vsync: this,
      duration: Duration(milliseconds: widget.value == -1 ? 2000 : 600),
    )..addListener(() {
        setState(() {});
      });
    if (widget.value == -1) {
      controller.repeat();
    } else {
      controller.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
      value: controller.value,
      strokeWidth: 3,
      semanticsLabel: 'Circular progress indicator',
    );
  }
}
