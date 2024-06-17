import 'package:flutter/material.dart';

class TransparentPageRoute extends PageRouteBuilder {
  final Widget widget;
  TransparentPageRoute(this.widget)
  : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) => widget,

    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
    ) {
      const begin = 0.0;
      const end = 1.0;
      const curve = Curves.easeInOut;

      var opacityTween = Tween<double>(begin: begin, end: end)
          .chain(CurveTween(curve: curve));

      var opacityAnimation = opacityTween.animate(animation);

      return FadeTransition(
        opacity: opacityAnimation,
        child: child,
      );
    },
  );
}
