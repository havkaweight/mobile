import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';

import 'package:health_tracker/model/data_items.dart';

import '../../model/user_product.dart';

class HavkaStackBarChartPainter extends CustomPainter {
  final List<PFCDataItem> nutritionData;
  HavkaStackBarChartPainter({required this.nutritionData});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..color = HavkaColors.cream;

    double left = 0.0;
    final double valuesSum = nutritionData
        .map((di) => di.value)
        .fold(0.0, (previousValue, element) => previousValue + element);
    for (final di in nutritionData) {
      final double barWidth = di.value / valuesSum * size.width;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, 0, barWidth, size.height),
        topLeft:
            di == nutritionData.first ? const Radius.circular(10) : Radius.zero,
        bottomLeft:
            di == nutritionData.first ? const Radius.circular(10) : Radius.zero,
        topRight:
            di == nutritionData.last ? const Radius.circular(10) : Radius.zero,
        bottomRight:
            di == nutritionData.last ? const Radius.circular(10) : Radius.zero,
      );
      final barPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawRRect(rect, barPaint);
      left += barWidth;
      if (di != nutritionData.last) {
        canvas.drawLine(
          Offset(left, 0),
          Offset(left, size.height),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HavkaStackBarChartPainter oldDelegate) => true;
}

class HavkaStackBarChart extends StatefulWidget {
  final List<UserProduct> initialData;
  const HavkaStackBarChart({required this.initialData});

  @override
  _HavkaStackBarChartState createState() => _HavkaStackBarChartState();
}

class _HavkaStackBarChartState extends State<HavkaStackBarChart> {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nutritionData.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 3.0),
                              child: Icon(
                                nutritionData[index].icon,
                                color: nutritionData[index].color,
                                size: 12,
                              ),
                            ),
                            Text(
                              nutritionData[index].label,
                              style: TextStyle(
                                color: nutritionData[index].color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: Text(
                      index != nutritionData.length - 1 ? '|' : '',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 215, 215, 215),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CustomPaint(
            painter: HavkaStackBarChartPainter(nutritionData: nutritionData),
            child: Container(
              height: 40,
            ),
          ),
        )
      ],
    );
  }

  @override
  void didUpdateWidget(covariant HavkaStackBarChart oldWidget) {
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
}
