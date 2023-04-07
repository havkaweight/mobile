import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class ModalScale extends StatefulWidget {
  final AnimationController animationController;

  const ModalScale({
    super.key,
    required this.animationController,
  });

  @override
  _ModalScaleState createState() => _ModalScaleState();
}

class _ModalScaleState extends State<ModalScale> with TickerProviderStateMixin {
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  double dragDistance = 0;
  double offset = 0;
  double? marginBottom = 10;
  double? marginRight = 10;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    fadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(widget.animationController);

    slideAnimation = Tween(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(widget.animationController);

    return Positioned(
      bottom: marginBottom,
      right: marginRight,
      child: Transform.translate(
        offset: Offset(offset, 0.0),
        child: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: GestureDetector(
              onTap: () {
                if (offset == 140) {
                  setState(() {
                    offset = 0;
                  });
                } else {
                  if (marginBottom == null) {
                    marginBottom = 10;
                    marginRight = 10;
                  } else {
                    marginBottom = null;
                    marginRight = null;
                  }
                }
              },
              onHorizontalDragDown: (DragDownDetails details) {
                setState(() {
                  dragDistance = 0;
                });
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  dragDistance += details.delta.dx;
                  if (dragDistance >= 0) {
                    offset = dragDistance;
                  } else {
                    offset += details.delta.dx / width * 100;
                  }
                });
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                setState(() {
                  if (dragDistance > 70) {
                    offset = 140;
                  } else {
                    dragDistance = 0;
                    offset = 0;
                  }
                });
              },
              child: Container(
                height: 75,
                width: 150,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 50.0,
                      spreadRadius: 1.0,
                      color: Colors.black38,
                    )
                  ],
                  color: HavkaColors.bone[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1),
                        (_) => Random().nextInt(300)),
                    builder: (context, snapshot) {
                      return Text(
                        '${snapshot.data ?? 10}g',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
