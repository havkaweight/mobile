import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/core/constants/colors.dart';
import '/data/models/pfc_data_item.dart';

class HavkaDonutChartPainter extends CustomPainter with ChangeNotifier {
  List<PFCDataItem> nutritionData;
  String? centerText;

  HavkaDonutChartPainter({
    required this.nutritionData,
    this.centerText,
  });

  late List<Path> segments;
  static const double deltaAngle = 2.0 * pi / 360.0;

  late double maxRadiusFactor;
  late double minRadiusFactor;

  @override
  void paint(Canvas canvas, Size size) {
    segments = [];
    final center = Offset(size.width / 2.0, size.height / 2.0);
    double startAngle = 0.0;
    final radius = size.width / 2.0;
    final totalSum =
        nutritionData.map((di) => di.value).reduce((a, b) => a + b);
    for (final di in nutritionData) {
      final sweepAngle = di.value / totalSum * 2.0 * pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      maxRadiusFactor = di.radius;
      minRadiusFactor = 0.5;
      canvas.drawPath(
        Path()
          ..addArc(
            Rect.fromCenter(
              center: center,
              width: radius * 2.0 * maxRadiusFactor,
              height: radius * 2.0 * maxRadiusFactor,
            ),
            startAngle,
            sweepAngle - deltaAngle,
          )
          ..lineTo(
            (center +
                    Offset(
                      radius *
                          minRadiusFactor *
                          cos(startAngle + sweepAngle - deltaAngle),
                      radius *
                          minRadiusFactor *
                          sin(
                            startAngle + sweepAngle - deltaAngle,
                          ),
                    ))
                .dx,
            (center +
                    Offset(
                      radius *
                          minRadiusFactor *
                          cos(startAngle + sweepAngle - deltaAngle),
                      radius *
                          minRadiusFactor *
                          sin(
                            startAngle + sweepAngle - deltaAngle,
                          ),
                    ))
                .dy,
          )
          ..addArc(
            Rect.fromCenter(
              center: center,
              width: radius * 2.0 * minRadiusFactor,
              height: radius * 2.0 * minRadiusFactor,
            ),
            startAngle + sweepAngle - deltaAngle,
            -sweepAngle + deltaAngle,
          )
          ..lineTo(
            (center +
                    Offset(
                      radius * maxRadiusFactor * cos(startAngle),
                      radius * maxRadiusFactor * sin(startAngle),
                    ))
                .dx,
            (center +
                    Offset(
                      radius * maxRadiusFactor * cos(startAngle),
                      radius * maxRadiusFactor * sin(startAngle),
                    ))
                .dy,
          ),
        paint,
      );
      segments.add(
        Path()
          ..addArc(
            Rect.fromCenter(
              center: center,
              width: radius * 2.0 * maxRadiusFactor,
              height: radius * 2.0 * maxRadiusFactor,
            ),
            startAngle,
            sweepAngle - deltaAngle,
          )
          ..lineTo(
            (center +
                    Offset(
                      radius *
                          minRadiusFactor *
                          cos(startAngle + sweepAngle - deltaAngle),
                      radius *
                          minRadiusFactor *
                          sin(startAngle + sweepAngle - deltaAngle),
                    ))
                .dx,
            (center +
                    Offset(
                      radius *
                          minRadiusFactor *
                          cos(startAngle + sweepAngle - deltaAngle),
                      radius *
                          minRadiusFactor *
                          sin(startAngle + sweepAngle - deltaAngle),
                    ))
                .dy,
          )
          ..addArc(
            Rect.fromCenter(
              center: center,
              width: radius * 2.0 * minRadiusFactor,
              height: radius * 2.0 * minRadiusFactor,
            ),
            startAngle + sweepAngle - deltaAngle,
            -sweepAngle + deltaAngle,
          )
          ..lineTo(
            (center +
                    Offset(
                      radius * maxRadiusFactor * cos(startAngle),
                      radius * maxRadiusFactor * sin(startAngle),
                    ))
                .dx,
            (center +
                    Offset(
                      radius * maxRadiusFactor * cos(startAngle),
                      radius * maxRadiusFactor * sin(startAngle),
                    ))
                .dy,
          ),
      );
      startAngle += sweepAngle;
    }

    final TextSpan textSpan = TextSpan(
      text: centerText,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: size.width / 15,
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

  @override
  bool hitTest(Offset position) {
    final List<double> oldRadiuses =
        nutritionData.map((e) => e.radius).toList();
    final List<double> newRadiuses =
        nutritionData.map((e) => e.radius).toList();

    final state =
        nutritionData.fold<double>(0, (sum, element) => sum + element.radius);
    for (final Path segment in segments) {
      if (segment.contains(position)) {
        if (state > 2.9 || oldRadiuses[segments.indexOf(segment)] < 0.9) {
          for (final Path s in segments) {
            if (s != segment) {
              newRadiuses[segments.indexOf(s)] = 0.8;
            } else {
              newRadiuses[segments.indexOf(s)] = 1.0;
            }
            centerText =
                '${nutritionData[segments.indexOf(segment)].value.toStringAsFixed(1)}g\n${nutritionData[segments.indexOf(segment)].label}';
          }
        } else {
          for (final Path s in segments) {
            newRadiuses[segments.indexOf(s)] = 1.0;
          }
          centerText = null;
        }
      }
    }

    final List<double> tempRadiuses = oldRadiuses;
    const int milliseconds = 30;
    Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
      if ((newRadiuses
                      .asMap()
                      .map(
                        (int index, double doub) =>
                            MapEntry(index, doub * pow(10, index)),
                      )
                      .values
                      .toList()
                      .fold<double>(0, (sum, el) => sum + el) -
                  tempRadiuses
                      .asMap()
                      .map(
                        (int index, double doub) =>
                            MapEntry(index, doub * pow(10, index)),
                      )
                      .values
                      .toList()
                      .fold<double>(0, (sum, el) => sum + el))
              .abs() <
          0.01) {
        for (int i = 0; i < tempRadiuses.length; i++) {
          nutritionData[i].radius = newRadiuses[i];
        }
        timer.cancel();
      } else {
        for (int i = 0; i < tempRadiuses.length; i++) {
          tempRadiuses[i] = tempRadiuses[i] +
              (newRadiuses[i] - tempRadiuses[i]) / milliseconds * 10;
          nutritionData[i].radius = tempRadiuses[i];
        }
      }
      notifyListeners();
    });
    return true;
  }
}

class HavkaDonutChart extends StatefulWidget {
  final double height;
  final List<PFCDataItem> initialData;
  final String? centerText;

  const HavkaDonutChart({
    super.key,
    this.height = 100,
    required this.initialData,
    this.centerText,
  });

  @override
  _HavkaDonutChartState createState() => _HavkaDonutChartState();
}

class _HavkaDonutChartState extends State<HavkaDonutChart> {
  late List<PFCDataItem> nutritionData;
  @override
  void initState() {
    super.initState();
    nutritionData = widget.initialData;
  }

  @override
  void didUpdateWidget(covariant HavkaDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    const int milliseconds = 50;
    if (widget.initialData != oldWidget.initialData) {
      final double oldProteins = oldWidget.initialData[0].value;
      final double oldFats = oldWidget.initialData[1].value;
      final double oldCarbs = oldWidget.initialData[2].value;

      final double newProteins = widget.initialData[0].value;
      final double newFats = widget.initialData[1].value;
      final double newCarbs = widget.initialData[2].value;

      double tempProteins = oldProteins;
      double tempFats = oldFats;
      double tempCarbs = oldCarbs;

      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        if ((newProteins - tempProteins).abs() < 0.01) {
          setState(() {
            nutritionData = [
              PFCDataItem(
                value: newProteins,
                label: "Protein",
                color: HavkaColors.protein,
                icon: FontAwesomeIcons.dna,
              ),
              PFCDataItem(
                value: newFats,
                label: "Fat",
                color: HavkaColors.fat,
                icon: FontAwesomeIcons.droplet,
              ),
              PFCDataItem(
                value: newCarbs,
                label: "Carbs",
                color: HavkaColors.carbs,
                icon: FontAwesomeIcons.wheatAwn,
              ),
            ];
          });
          timer.cancel();
        } else {
          setState(() {
            tempProteins =
                tempProteins + (newProteins - tempProteins) / milliseconds * 10;
            tempFats = tempFats + (newFats - tempFats) / milliseconds * 10;
            tempCarbs = tempCarbs + (newCarbs - tempCarbs) / milliseconds * 10;
            nutritionData = [
              PFCDataItem(
                value: tempProteins,
                label: "Protein",
                color: HavkaColors.protein,
                icon: FontAwesomeIcons.dna,
              ),
              PFCDataItem(
                value: tempFats,
                label: "Fat",
                color: HavkaColors.fat,
                icon: FontAwesomeIcons.droplet,
              ),
              PFCDataItem(
                value: tempCarbs,
                label: "Carbs",
                color: HavkaColors.carbs,
                icon: FontAwesomeIcons.wheatAwn,
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
        centerText: widget.centerText,
      ),
      child: Container(
        height: widget.height,
        width: widget.height,
      ),
    );
  }
}
