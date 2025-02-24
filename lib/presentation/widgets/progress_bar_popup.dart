import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import '/presentation/widgets/progress_bar.dart';

class ProgressBarPopup extends StatefulWidget {
  final AnimationController animationController;
  final double value;

  const ProgressBarPopup({
    super.key,
    required this.animationController,
    required this.value,
  });

  @override
  _ProgressBarPopupState createState() => _ProgressBarPopupState();
}

class _ProgressBarPopupState extends State<ProgressBarPopup>
    with TickerProviderStateMixin {
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late ValueNotifier<double> progressBarValueNotifier;

  @override
  void initState() {
    super.initState();
    progressBarValueNotifier = ValueNotifier(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    fadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(widget.animationController);

    slideAnimation = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(widget.animationController);

    return Positioned.fromRect(
      rect: Rect.fromLTWH(
        MediaQuery.of(context).size.width * 0.1,
        MediaQuery.of(context).size.height * 0.85,
        MediaQuery.of(context).size.width * 0.8,
        MediaQuery.of(context).size.height * 0.085,
      ),
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: PhysicalModel(
            color: HavkaColors.cream.withOpacity(0.95),
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    width: 0.4,
                    color: HavkaColors.energy,
                    strokeAlign: BorderSide.strokeAlignOutside),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Daily goal',
                    style: TextStyle(
                      color: HavkaColors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: progressBarValueNotifier,
                    builder: (context, double progressBarValue, child) =>
                        HavkaProgressBar(
                      value: progressBarValue,
                      maxValue: 3000,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ProgressBarPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        progressBarValueNotifier.value = widget.value;
      });
    }
  }
}
