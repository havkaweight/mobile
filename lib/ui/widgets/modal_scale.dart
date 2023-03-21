import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/weightings_screen.dart';

class ModalScale extends StatefulWidget {
  final AnimationController animationController;

  ModalScale({
    super.key,
    required this.animationController,
  });

  _ModalScaleState createState() => _ModalScaleState();
}

class _ModalScaleState extends State<ModalScale> {
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  double dragDistance = 0;
  double offset = 0;

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
      bottom: 10,
      right: 10,
      child: Transform.translate(
        offset: Offset(offset, 0.0),
        child: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: GestureDetector(
              onTap: () {
                if(offset == 140) {
                  setState(() {
                    offset = 0;
                  });
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WeightingsScreen()));
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
                  if(details.delta.dx >= 0) {
                    offset = dragDistance;
                  } else {
                    offset += details.delta.dx / width * 100;
                  }
                });
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                setState(() {
                  if(dragDistance > 70) {
                    offset = 140;
                  } else {
                    dragDistance = 0;
                    offset = 0;
                  }
                });
              },
              child: Hero(
                tag: 'mini-scale',
                child: Container(
                  height: 75,
                  width: 150,
                  decoration: BoxDecoration(
                    boxShadow: const[
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
                        stream: Stream.periodic(const Duration(seconds: 1), (_) => Random().nextInt(300)),
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
      ),
    );
  }
}
