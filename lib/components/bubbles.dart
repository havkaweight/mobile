import 'dart:math';

import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Bubbles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BubblesState();
}

class _BubblesState extends State<Bubbles> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  List<Bubble>? bubbles;
  final int numberOfBubbles = 100;
  final Color color = HavkaColors.green;
  final Color bgColor = HavkaColors.cream;
  final double maxBubbleSize = 10.0;

  @override
  void initState() {
    super.initState();

    // Initialize bubbles
    bubbles = [];
    int i = numberOfBubbles;
    while (i > 0) {
      bubbles!.add(Bubble(color, maxBubbleSize));
      i--;
    }

    // Init animation controller
    _controller = AnimationController(
        duration: const Duration(seconds: 1000), vsync: this);
    _controller!.addListener(() {
      updateBubblePosition();
    });
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomPaint(
        foregroundPainter:
        BubblePainter(bubbles: bubbles, controller: _controller),
        size: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        ),
    );
  }

  void updateBubblePosition() {
    bubbles!.forEach((it) => it.updatePosition());
    setState(() {});
  }
}

class BubblePainter extends CustomPainter {
  List<Bubble>? bubbles;
  AnimationController? controller;

  BubblePainter({this.bubbles, this.controller});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    bubbles!.forEach((it) => it.draw(canvas, canvasSize));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Bubble {
  Color? color;
  double? direction;
  double? speed;
  double? radius;
  double? x;
  double? y;

  Bubble(Color color, double maxBubbleSize) {
    this.color = color.withOpacity(Random().nextDouble());
    this.direction = Random().nextDouble() * 360;
    this.speed = 1;
    this.radius = Random().nextDouble() * maxBubbleSize;
  }

  draw(Canvas canvas, Size canvasSize) {
    Paint paint = new Paint()
      ..color = color!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    assignRandomPositionIfUninitialized(canvasSize);

    randomlyChangeDirectionIfEdgeReached(canvasSize);

    canvas.drawCircle(Offset(x!, y!), radius!, paint);
  }

  void assignRandomPositionIfUninitialized(Size canvasSize) {
    if (x == null) {
      this.x = Random().nextDouble() * canvasSize.width;
    }

    if (y == null) {
      this.y = Random().nextDouble() * canvasSize.height;
    }
  }

  updatePosition() {
    var a = 180 - (direction! + 90);
    direction! > 0 && direction! < 180
        ? x = x! + speed! * sin(direction!) / sin(speed!)
        : x = x! - speed! * sin(direction!) / sin(speed!);
    direction! > 90 && direction! < 270
        ? y = y! + speed! * sin(a) / sin(speed!)
        : y = y! - speed! * sin(a) / sin(speed!);
  }

  randomlyChangeDirectionIfEdgeReached(Size canvasSize) {
    if (x! > canvasSize.width || x! < 0 || y! > canvasSize.height || y! < 0) {
      direction = Random().nextDouble() * 360;
    }
  }
}