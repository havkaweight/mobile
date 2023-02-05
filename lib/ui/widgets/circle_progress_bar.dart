import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgressBar extends CustomPainter {
  final double value;
  Color color = Colors.grey;

  CircleProgressBar(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final area = Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 1,
    );

    if(value > 0.8) {
      color = Colors.green;
    } else if(value > 0.5) {
      color = Colors.amber;
    } else {
      color = Colors.red;
    }

    canvas.drawArc(
        area,
        -pi / 2,
        2 * pi * value,
        true,
        Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CircularProgressBar extends StatefulWidget {
  final double value;

  const CircularProgressBar({
    super.key,
    required this.value,
});
  @override
  State<CircularProgressBar> createState() =>
      _CircularProgressBar();
}

class _CircularProgressBar extends State<CircularProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late final Color color;
  @override
  void initState() {
    if(widget.value > 0.8) {
      color = Colors.green;
    } else if(widget.value > 0.5) {
      color = Colors.amber;
    } else {
      color = Colors.red;
    }
    controller = AnimationController(
      value: 0,
      upperBound: widget.value,
      vsync: this,
      duration: const Duration(milliseconds:  600),
    )
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
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