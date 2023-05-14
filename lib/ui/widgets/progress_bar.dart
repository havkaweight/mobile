import 'dart:async';

import 'package:flutter/material.dart';

import 'package:health_tracker/constants/colors.dart';

class HavkaProgressBarPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final double minValue;
  HavkaProgressBarPainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barStrokePaint = Paint()
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke
      ..color = HavkaColors.kcal;

    final barFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = HavkaColors.fat.withOpacity(0.2);

    final barCurrentValuePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = HavkaColors.fat;

    final barCurrentValueShadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = HavkaColors.black
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3 * 0.57735 + 0.5);

    final barEntry = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(barEntry, barFillPaint);

    final barCurrentValue = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        0,
        value / (maxValue - minValue) * size.width,
        size.height,
      ),
      const Radius.circular(10),
    );
    // canvas.drawRRect(barCurrentValue, barCurrentValueShadowPaint);
    canvas.drawRRect(barCurrentValue, barCurrentValuePaint);

    final barBorders = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(barBorders, barStrokePaint);

    final TextSpan textSpan = TextSpan(
      text: '${value.toStringAsFixed(0)} / ${maxValue.toStringAsFixed(0)}',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width * 0.97 - textPainter.width,
        size.height / 2.0 - textPainter.height / 2.0,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant HavkaProgressBarPainter oldDelegate) => true;
}

class HavkaProgressBar extends StatefulWidget {
  final double value;
  final double minValue;
  final double maxValue;
  const HavkaProgressBar({
    this.value = 0,
    this.minValue = 0,
    this.maxValue = 1,
  });

  @override
  _HavkaProgressBarState createState() => _HavkaProgressBarState();
}

class _HavkaProgressBarState extends State<HavkaProgressBar> {
  late double value;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: CustomPaint(
            painter: HavkaProgressBarPainter(
              value: value,
              minValue: widget.minValue,
              maxValue: widget.maxValue,
            ),
            child: Container(
              height: 30,
            ),
          ),
        )
      ],
    );
  }

  @override
  void didUpdateWidget(covariant HavkaProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      double tempValue = oldWidget.value;
      const int milliseconds = 30;
      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        if ((tempValue - widget.value).abs() < 0.01) {
          timer.cancel();
        } else {
          tempValue = tempValue + (widget.value - tempValue) / milliseconds * 5;
          setState(() {
            value = tempValue;
          });
        }
      });
    }
  }
}
