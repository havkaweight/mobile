import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

import 'package:health_tracker/model/data_items.dart';

class HavkaStackBarChartPaint extends CustomPainter {
  final List<PFCDataItem> data;
  HavkaStackBarChartPaint({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..color = HavkaColors.cream;

    double left = 0.0;
    final double valuesSum = data
        .map((di) => di.value)
        .fold(0.0, (previousValue, element) => previousValue + element);
    for (final di in data) {
      final double barWidth = di.value / valuesSum * size.width;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, 0, barWidth, size.height),
        topLeft: di == data.first ? const Radius.circular(10) : Radius.zero,
        bottomLeft: di == data.first ? const Radius.circular(10) : Radius.zero,
        topRight: di == data.last ? const Radius.circular(10) : Radius.zero,
        bottomRight: di == data.last ? const Radius.circular(10) : Radius.zero,
      );
      final barPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = di.color;
      canvas.drawRRect(rect, barPaint);
      left += barWidth;
      if (di != data.last) {
        canvas.drawLine(
          Offset(left, 0),
          Offset(left, size.height),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HavkaStackBarChartPaint oldDelegate) => true;
}

class HavkaStackBarChart extends StatefulWidget {
  final List<PFCDataItem> data;
  const HavkaStackBarChart({required this.data});

  @override
  _HavkaStackBarChartState createState() => _HavkaStackBarChartState();
}

class _HavkaStackBarChartState extends State<HavkaStackBarChart> {
  @override
  void initState() {
    super.initState();
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
            itemCount: widget.data.length,
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
                                widget.data[index].icon,
                                color: widget.data[index].color,
                                size: 12,
                              ),
                            ),
                            Text(
                              widget.data[index].label,
                              style: TextStyle(
                                color: widget.data[index].color,
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
                      index != widget.data.length - 1 ? '|' : '',
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
            painter: HavkaStackBarChartPaint(data: widget.data),
            child: Container(
              height: 40,
            ),
          ),
        )
      ],
    );
  }
}
