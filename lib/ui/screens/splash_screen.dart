import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(() {
        if (_controller.value > 0.5) {
          _controller.value = 0.5;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: const Center(
        child: Hero(
          tag: "splash-logo",
          child: AppIcon(image: Assets.appLogo),
        ),
      ),
    );
  }
}
