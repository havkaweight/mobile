import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/data_items.dart';
import 'package:health_tracker/model/user_product.dart';

class HavkaDonutChartPainter extends CustomPainter {
  final List<PFCDataItem> nutritionData;
  final String? centerText;
  HavkaDonutChartPainter({
    required this.nutritionData,
    this.centerText,
  });

  final linePaint = Paint()
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke
    ..color = Colors.white;

  final midPaint = Paint()
    ..color = HavkaColors.cream
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    double startAngle = 0.0;
    final radius = size.width;
    final rect = Rect.fromCenter(center: center, width: radius, height: radius);
    final totalSum =
        nutritionData.map((di) => di.value).reduce((a, b) => a + b);
    for (final di in nutritionData) {
      final sweepAngle = di.value / totalSum * 2.0 * pi;
      final dx = radius / 2.0 * cos(startAngle);
      final dy = radius / 2.0 * sin(startAngle);
      final p2 = center + Offset(dx, dy);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      canvas.drawLine(center, p2, linePaint);
      startAngle += sweepAngle;
    }
    canvas.drawCircle(center, radius * 0.3, midPaint);

    final TextSpan textSpan = TextSpan(
      text: centerText,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: size.width / 5,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center + Offset(-textPainter.width / 2.0, -textPainter.height / 2.0),
    );
  }

  @override
  bool shouldRepaint(covariant HavkaDonutChartPainter oldDelegate) => true;
}

class HavkaDonutChart extends StatefulWidget {
  final List<UserProduct> initialData;
  const HavkaDonutChart({
    super.key,
    required this.initialData,
  });

  @override
  _HavkaDonutChartState createState() => _HavkaDonutChartState();
}

class _HavkaDonutChartState extends State<HavkaDonutChart> {
  late double proteins;
  late double fats;
  late double carbs;
  late List<PFCDataItem> nutritionData;

  @override
  void initState() {
    super.initState();
    proteins = widget.initialData.fold<double>(
      0,
      (sum, element) {
        if (element.product!.nutrition!.protein != null) {
          return sum + element.product!.nutrition!.protein!;
        }
        return sum;
      },
    );

    fats = widget.initialData.fold<double>(
      0,
      (sum, element) {
        if (element.product!.nutrition!.fat != null) {
          return sum + element.product!.nutrition!.fat!;
        }
        return sum;
      },
    );

    carbs = widget.initialData.fold<double>(
      0,
      (sum, element) {
        if (element.product!.nutrition!.carbs != null) {
          return sum + element.product!.nutrition!.carbs!;
        }
        return sum;
      },
    );
    nutritionData = [
      PFCDataItem(
        proteins,
        "Protein",
        HavkaColors.protein,
        FontAwesomeIcons.dna,
      ),
      PFCDataItem(
        fats,
        "Fat",
        HavkaColors.fat,
        FontAwesomeIcons.droplet,
      ),
      PFCDataItem(
        carbs,
        "Carbs",
        HavkaColors.carbs,
        FontAwesomeIcons.wheatAwn,
      ),
    ];
  }

  @override
  void didUpdateWidget(covariant HavkaDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      final double oldProteins = oldWidget.initialData.fold<double>(
        0,
        (sum, element) {
          if (element.product!.nutrition!.protein != null) {
            return sum + element.product!.nutrition!.protein!;
          }
          return sum;
        },
      );

      final double oldFats = oldWidget.initialData.fold<double>(
        0,
        (sum, element) {
          if (element.product!.nutrition!.fat != null) {
            return sum + element.product!.nutrition!.fat!;
          }
          return sum;
        },
      );

      final double oldCarbs = oldWidget.initialData.fold<double>(
        0,
        (sum, element) {
          if (element.product!.nutrition!.carbs != null) {
            return sum + element.product!.nutrition!.carbs!;
          }
          return sum;
        },
      );

      final double newProteins = widget.initialData.fold<double>(
        0,
        (sum, element) {
          if (element.product!.nutrition!.protein != null) {
            return sum + element.product!.nutrition!.protein!;
          }
          return sum;
        },
      );

      final double newFats = widget.initialData.fold<double>(
        0,
        (sum, element) {
          if (element.product!.nutrition!.fat != null) {
            return sum + element.product!.nutrition!.fat!;
          }
          return sum;
        },
      );

      final double newCarbs = widget.initialData.fold<double>(
        0,
        (sum, element) {
          if (element.product!.nutrition!.carbs != null) {
            return sum + element.product!.nutrition!.carbs!;
          }
          return sum;
        },
      );
      double tempProteins = oldProteins;
      double tempFats = oldFats;
      double tempCarbs = oldCarbs;
      const int milliseconds = 50;
      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        if ((newProteins - tempProteins).abs() < 0.01) {
          timer.cancel();
        } else {
          setState(() {
            tempProteins =
                tempProteins + (newProteins - tempProteins) / milliseconds * 10;
            proteins = tempProteins;
            tempFats = tempFats + (newFats - tempFats) / milliseconds * 10;
            fats = tempFats;
            tempCarbs = tempCarbs + (newCarbs - tempCarbs) / milliseconds * 10;
            carbs = tempCarbs;
            nutritionData = [
              PFCDataItem(
                proteins,
                "Protein",
                HavkaColors.protein,
                FontAwesomeIcons.dna,
              ),
              PFCDataItem(
                fats,
                "Fat",
                HavkaColors.fat,
                FontAwesomeIcons.droplet,
              ),
              PFCDataItem(
                carbs,
                "Carbs",
                HavkaColors.carbs,
                FontAwesomeIcons.wheatAwn,
              ),
            ];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HavkaDonutChartPainter(
        nutritionData: nutritionData,
        centerText: widget.initialData.length.toString(),
      ),
      child: Container(),
    );
  }
}
