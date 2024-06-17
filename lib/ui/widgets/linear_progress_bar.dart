import 'package:flutter/material.dart';
import 'package:havka/constants/colors.dart';

class LinearProgressBar extends StatefulWidget {
  const LinearProgressBar({
    super.key,
  });

  @override
  _LinearProgressBar createState() => _LinearProgressBar();
}

class _LinearProgressBar extends State<LinearProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      value: 0,
      upperBound: 100,
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          backgroundColor: HavkaColors.green.withOpacity(0.2),
          color: HavkaColors.green,
          minHeight: 5,
          value: controller.value,
          semanticsLabel: 'Linear progress indicator',
        ),
      ),
    );
  }
}

class StaticLinearProgressBar extends StatelessWidget {
  final double percentWatched;
  const StaticLinearProgressBar({
    super.key,
    required this.percentWatched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          backgroundColor: HavkaColors.green.withOpacity(0.2),
          color: HavkaColors.green,
          minHeight: 5,
          value: percentWatched,
          semanticsLabel: 'Linear progress indicator',
        ),
      ),
    );
  }
}
