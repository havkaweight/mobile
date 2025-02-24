import 'package:flutter/material.dart';

import '/core/constants/assets.dart';
import '/core/constants/colors.dart';
import '/presentation/widgets/app_icon.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "splash-logo",
              child: AppIcon(image: Assets.appLogo),
            ),
            Text(
              "Havka",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HavkaColors.green,
                fontSize: 30
              ),
            )
          ],
        ),
      ),
    );
  }
}
