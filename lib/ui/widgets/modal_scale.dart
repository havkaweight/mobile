import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/weightings_screen.dart';

class ModalScale extends StatelessWidget {
  final AnimationController animationController;

  ModalScale({
    super.key,
    required this.animationController,
  });

  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  Widget build(BuildContext context) {
    fadeAnimation = Tween(
        begin: 0.0,
        end: 1.0,
    ).animate(animationController);

    slideAnimation = Tween(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
    ).animate(animationController);

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => Random().nextInt(300)),
      builder: (context, snapshot) {
        return Positioned(
          bottom: 10,
          right: 10,
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Hero(
                tag: 'mini-scale',
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductAddingScreen()));
                  },
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
                        child: Text(
                            '${snapshot.data ?? 10}g',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                            ),
                        ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
