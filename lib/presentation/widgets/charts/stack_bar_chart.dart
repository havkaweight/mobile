import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/data/models/pfc_data_item.dart';

class HavkaStackBarChartPainter extends CustomPainter with ChangeNotifier {
  final List<PFCDataItem> nutritionData;
  final Function(int)? onTapBar;

  HavkaStackBarChartPainter({
    required this.nutritionData,
    this.onTapBar,
  });

  late List<Path> bars;

  @override
  void paint(Canvas canvas, Size size) {
    if (nutritionData.first.value == 0) {return;}
    bars = [];

    double left = 0.0;
    final double valuesSum = nutritionData
        .map((di) => di.value)
        .fold(0.0, (previousValue, element) => previousValue + element);
    for (final di in nutritionData) {
      final double barWidth = di.value / valuesSum * size.width;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          left,
          (size.height - size.height * di.radius) / 2.0,
          barWidth - size.width * 0.01,
          size.height * di.radius,
        ),
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
      bars.add(Path()..addRRect(rect));
      left += barWidth;
    }
  }

  @override
  bool shouldRepaint(covariant HavkaStackBarChartPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    final List<double> oldRadiuses =
        nutritionData.map((e) => e.radius).toList();
    final List<double> newRadiuses =
        nutritionData.map((e) => e.radius).toList();

    final state =
        nutritionData.fold<double>(0, (sum, element) => sum + element.radius);
    for (final Path bar in bars) {
      if (bar.contains(position)) {
        if (state > 2.9 || oldRadiuses[bars.indexOf(bar)] < 0.9) {
          onTapBar!(bars.indexOf(bar));
          for (final Path b in bars) {
            if (b != bar) {
              newRadiuses[bars.indexOf(b)] = 0.7;
            } else {
              newRadiuses[bars.indexOf(b)] = 1.0;
            }
          }
        } else {
          onTapBar!(-1);
          for (final Path b in bars) {
            newRadiuses[bars.indexOf(b)] = 1.0;
          }
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

class HavkaStackBarChart extends StatefulWidget {
  final List<PFCDataItem> initialData;
  final Function(int)? onTapBar;
  final bool showLegend;

  const HavkaStackBarChart({
    required this.initialData,
    this.onTapBar,
    this.showLegend = true,
  });

  @override
  _HavkaStackBarChartState createState() => _HavkaStackBarChartState();
}

class _HavkaStackBarChartState extends State<HavkaStackBarChart> {
  late List<PFCDataItem> nutritionData;

  @override
  void initState() {
    super.initState();
    nutritionData = widget.initialData;
  }

  @override
  Widget build(BuildContext context) {
    return nutritionData.length > 0 ?
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showLegend ? SizedBox(
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
        )
        : SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CustomPaint(
            painter: HavkaStackBarChartPainter(
                nutritionData: nutritionData, onTapBar: widget.onTapBar),
            child: Container(
              height: 40,
            ),
          ),
        )
      ],
    ) :
    SizedBox();
  }

  @override
  void didUpdateWidget(covariant HavkaStackBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData && nutritionData.length > 0) {

      if(widget.initialData.length == 0) {
        setState(() {
          nutritionData = [
            PFCDataItem(value: 1, icon: Icons.circle, label: "Fill up your fridge to see the stats", color: Colors.grey.withOpacity(0.5))
          ];
        });
        return;
      }

      if(oldWidget.initialData.length == 0 && widget.initialData != 0) {
        setState(() {
          nutritionData = widget.initialData;
        });
        return;
      }

      final newNutritionData = widget.initialData.map((e) => e.value).toList();
      final tempNutritionData =
          oldWidget.initialData.map((e) => e.value).toList();

      const int milliseconds = 35;
      Timer.periodic(const Duration(milliseconds: milliseconds), (timer) {
        if ((newNutritionData[0] - tempNutritionData[0]).abs() < 0.01) {
          timer.cancel();
          for (int i=0; i<tempNutritionData.length; i++) {
            nutritionData[i].value = newNutritionData[i];
          }
        } else {
          setState(() {
            for (int i=0; i<tempNutritionData.length; i++) {
              tempNutritionData[i] +=
                  (newNutritionData[i] - tempNutritionData[i]) /
                      milliseconds *
                      10;
              nutritionData[i].value = tempNutritionData[i];
            }
          });
        }
      });
    }
  }
}
