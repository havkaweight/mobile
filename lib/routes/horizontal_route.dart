import 'package:flutter/material.dart';

class HorizontalRoute extends PageRouteBuilder {
  final Widget widget;

  HorizontalRoute(this.widget) : super(
    transitionDuration: const Duration(seconds: 3),

    pageBuilder: (BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation) {
      return widget;
    },

    transitionsBuilder: (BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn)),
        child: child,
      );
    },
  );
}