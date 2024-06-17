import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:havka/constants/colors.dart';

import 'package:havka/model/data_items.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';

class HavkaLineChartPainter extends CustomPainter {
  List<DataPoint> initialData;
  final double? minTargetValue;
  final double? maxTargetValue;
  final double? targetValue;
  final String? targetLabel;
  final bool showZeroAxis;
  final bool showTime;
  final bool isCumulative;
  final bool fillArea;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;
  final Function valuesFormat;

  HavkaLineChartPainter({
    required this.initialData,
    this.minTargetValue,
    this.maxTargetValue,
    this.targetValue,
    this.targetLabel,
    required this.showZeroAxis,
    required this.showTime,
    required this.isCumulative,
    required this.fillArea,
    this.minDateTime,
    this.maxDateTime,
    required this.valuesFormat,
  });

  @override
  void paint(Canvas canvas, Size size) {

    if(initialData.isEmpty) {
      return;
    }

    final linePaint = Paint()
      ..color = HavkaColors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [HavkaColors.green.withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromPoints(Offset(0, 0), Offset(0, size.height)))
      ..style = PaintingStyle.fill;

    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = HavkaColors.green.withOpacity(0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    initialData.sort((a, b) => a.dx.compareTo(b.dx));

    int firstDate;
    int lastDate;
    if (showTime) {
      firstDate = (initialData.first.dx.millisecondsSinceEpoch / 3600000).round();
      lastDate = (initialData.last.dx.millisecondsSinceEpoch / 3600000).round();

      if(minDateTime != null) {
        firstDate = (minDateTime!.millisecondsSinceEpoch / 3600000).round();
      }

      if(maxDateTime != null) {
        lastDate = (maxDateTime!.millisecondsSinceEpoch / 3600000).round();
      }
    } else {
      firstDate = (initialData.first.dx.millisecondsSinceEpoch / 86400000).round();
      lastDate = (initialData.last.dx.millisecondsSinceEpoch / 86400000).round();

      if(minDateTime != null) {
        firstDate = (minDateTime!.millisecondsSinceEpoch / 86400000).round();
      }

      if(maxDateTime != null) {
        lastDate = (maxDateTime!.millisecondsSinceEpoch / 86400000).round();
      }
    }

    int totalWidth = 0;

    if(minDateTime != null && maxDateTime != null) {
      totalWidth = maxDateTime!.millisecondsSinceEpoch - minDateTime!.millisecondsSinceEpoch;
    } else if (minDateTime != null) {
      totalWidth = initialData.last.dx.millisecondsSinceEpoch - minDateTime!.millisecondsSinceEpoch;
    } else if (maxDateTime != null) {
      totalWidth = maxDateTime!.millisecondsSinceEpoch - initialData.first.dx.millisecondsSinceEpoch;
    } else {
      if(initialData.length > 1) {
        totalWidth = initialData.last.dx.millisecondsSinceEpoch - initialData.first.dx.millisecondsSinceEpoch;
      }
    }

    double maxHeight = initialData.map((el) => el.dy).reduce(max);
    double minHeight = initialData.map((el) => el.dy).reduce(min);
    if(isCumulative) {
      maxHeight = initialData.map((el) => el.dy).fold(0.0, (previousValue, element) => previousValue + element);
      minHeight = initialData.first.dy;
    }

    if (minTargetValue != null) {
      minHeight = min(minHeight, minTargetValue!);
    }
    if (maxTargetValue != null) {
      maxHeight = max(maxHeight, maxTargetValue!);
    }
    if (targetValue != null) {
      maxHeight = max(maxHeight, targetValue!);
    }

    if (showZeroAxis) {
      minHeight = min(minHeight, 0);
      maxHeight = maxHeight + (maxHeight-minHeight) / 2.0;
    }

    final double upperBound = maxHeight.round() + 2;
    final double lowerBound = max(minHeight.round() - 2, 0);

    final double totalHeight = upperBound - lowerBound;
    final int targetStepsCount = 10;

    List<double> niceStepSizes = [0.1, 0.2, 0.5, 1.0, 5.0, 10.0, 20.0, 30.0, 40.0, 50.0, 100.0, 500.0, 1000.0];
    final double verticalStep = niceStepSizes.firstWhere((step) => totalHeight / step <= targetStepsCount, orElse: () => niceStepSizes.last);

    final TextSpan maxValueSpan = TextSpan(
      text: upperBound.toStringAsFixed(3),
      style: TextStyle(
        color: Colors.grey,
        fontSize: 11,
      ),
    );

    final TextPainter maxValuePainter = TextPainter(
      text: maxValueSpan,
      textAlign: TextAlign.left,
      textDirection: ui.TextDirection.ltr,
    );

    maxValuePainter.layout();
    final double left = maxValuePainter.width;

    final TextSpan verticalAxisMaxValueSpan = TextSpan(
      text: "30",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 11,
      ),
    );

    final TextPainter verticalAxisMaxValuePainter = TextPainter(
      text: verticalAxisMaxValueSpan,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    verticalAxisMaxValuePainter.layout();

    final horizontalAxis = Path()
      ..moveTo(
          left - verticalAxisMaxValuePainter.height / 1.5,
          size.height - verticalAxisMaxValuePainter.height * 1.7
      )
      ..lineTo(
          size.width - verticalAxisMaxValuePainter.height / 1.5,
          size.height - verticalAxisMaxValuePainter.height * 1.7
      );

    final normalizedWidth = totalWidth / (size.width - left - 4 * verticalAxisMaxValuePainter.height / 3);
    final normalizedHeight = totalHeight / (size.height - verticalAxisMaxValuePainter.height * 3.4);
    final len = DateTime.fromMillisecondsSinceEpoch(lastDate * (showTime ? 3600000 : 86400000)).difference(DateTime.fromMillisecondsSinceEpoch(firstDate * (showTime ? 3600000 : 86400000)));
    num lenInValue = showTime ? len.inHours : len.inDays;

    final TextPainter testPainter = TextPainter(
      text: TextSpan(
        text: "99",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );


    int skipCount = 1;
    testPainter.layout();

    for(int i=1; i<100; i++) {
      if (testPainter.width * lenInValue <= size.width * 0.8) {
        skipCount = i;
        break;
      }
      lenInValue /= i;
    }

    for(int i=firstDate; i<lastDate+1; i++) {
      final horizontalStep = i * (showTime ? 3600000 : 86400000);

      final verticalLine = Path()
        ..moveTo(
            left + (horizontalStep - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            verticalAxisMaxValuePainter.height * 1.2
        )
        ..lineTo(
            left + (horizontalStep - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.2
        );

      canvas.drawPath(verticalLine, gridPaint);

      final TextSpan verticalAxisValueSpan = TextSpan(
        text: showTime ? DateTime.fromMillisecondsSinceEpoch(horizontalStep).hour.toString() : DateFormat("d").format(DateTime.fromMillisecondsSinceEpoch(horizontalStep)),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      );

      final TextPainter verticalAxisValuePainter = TextPainter(
        text: verticalAxisValueSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );

      verticalAxisValuePainter.layout();
      if ((lastDate - i) % skipCount == 0) {
        verticalAxisValuePainter.paint(
          canvas,
          Offset(
            left + (horizontalStep - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth - verticalAxisValuePainter.width / 2.0,
            size.height - verticalAxisValuePainter.height,
          ),
        );
      }
    }

    for(double i=lowerBound; i<upperBound+1; i+=verticalStep) {
      final horizontalLine = Path()
        ..moveTo(
            left - verticalAxisMaxValuePainter.height / 1.5,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (i - lowerBound) / normalizedHeight
        )
        ..lineTo(
            size.width - verticalAxisMaxValuePainter.height / 1.5,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (i - lowerBound) / normalizedHeight
        );
      canvas.drawPath(horizontalLine, gridPaint);

      final TextSpan horizontalAxisValueSpan = TextSpan(
        text: i.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      );

      final TextPainter horizontalAxisValuePainter = TextPainter(
        text: horizontalAxisValueSpan,
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr,
      );

      horizontalAxisValuePainter.layout();
      horizontalAxisValuePainter.paint(
        canvas,
        Offset(
            0,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (i - lowerBound) / normalizedHeight - horizontalAxisValuePainter.height / 2.0
        ),
      );
    }


    if (minTargetValue != null || maxTargetValue != null || targetValue != null) {
      final targetPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.grey;

      for(double i=left - verticalAxisMaxValuePainter.height / 1.5; i<size.width - verticalAxisMaxValuePainter.height / 1.5; i+=size.width/20) {

        if(minTargetValue != null) {
          final minTargetLine = Path()
            ..moveTo(
                i,
                size.height - verticalAxisMaxValuePainter.height * 1.7 - (minTargetValue! - lowerBound) / normalizedHeight,
            )
            ..lineTo(
                i+size.width/20*0.7,
                size.height - verticalAxisMaxValuePainter.height * 1.7 - (minTargetValue! - lowerBound) / normalizedHeight
            );

          canvas.drawPath(minTargetLine, targetPaint);
        }

        if(maxTargetValue != null) {
          final maxTargetLine = Path()
            ..moveTo(
                i,
                size.height - verticalAxisMaxValuePainter.height * 1.7 - (maxTargetValue! - lowerBound) / normalizedHeight
            )
            ..lineTo(
                i+size.width/30,
                size.height - verticalAxisMaxValuePainter.height * 1.7 - (maxTargetValue! - lowerBound) / normalizedHeight
            );

          canvas.drawPath(maxTargetLine, targetPaint);
        }

        if(targetValue != null) {
          final targetLine = Path()
            ..moveTo(
                i,
                size.height - verticalAxisMaxValuePainter.height * 1.7 - (targetValue! - lowerBound) / normalizedHeight
            )
            ..lineTo(
                i+size.width/30,
                size.height - verticalAxisMaxValuePainter.height * 1.7 - (targetValue! - lowerBound) / normalizedHeight
            );

          canvas.drawPath(targetLine, targetPaint);
        }
      }

      if (targetValue != null) {
        TextPainter targetLabelPainter = TextPainter();
        if(targetLabel != null) {
          final targetLabelSpan = TextSpan(
            text: "${targetLabel} - ",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          );

          targetLabelPainter = TextPainter(
            text: targetLabelSpan,
            textAlign: TextAlign.left,
            textDirection: ui.TextDirection.ltr,
          );

          targetLabelPainter.layout();
          targetLabelPainter.paint(
            canvas,
            Offset(
              left - verticalAxisMaxValuePainter.height / 1.5,
              size.height - verticalAxisMaxValuePainter.height * 1.7 - (targetValue! - lowerBound) / normalizedHeight - 1.2 * verticalAxisMaxValuePainter.height,
            ),
          );
        }

        final targetValueSpan = TextSpan(
          text: "${Utils().formatNumber(targetValue)} kcal",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        );

        final targetValuePainter = TextPainter(
          text: targetValueSpan,
          textAlign: TextAlign.left,
          textDirection: ui.TextDirection.ltr,
        );

        targetValuePainter.layout();
        targetValuePainter.paint(
          canvas,
          Offset(
            left - verticalAxisMaxValuePainter.height / 1.5 + (targetLabel != null ? targetLabelPainter.width : 0),
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (targetValue! - lowerBound) / normalizedHeight - 1.2 * verticalAxisMaxValuePainter.height,
          ),
        );
      }

      if(minTargetValue != null || maxTargetValue != null) {
        final targetAreaPaint = Paint()
          ..color = Colors.black.withOpacity(0.03)
          ..strokeWidth = 1
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              left - verticalAxisMaxValuePainter.height / 1.5,
              size.height - verticalAxisMaxValuePainter.height * 1.7 - (maxTargetValue! - lowerBound) / normalizedHeight,
              size.width - verticalAxisMaxValuePainter.height / 1.5,
              size.height - verticalAxisMaxValuePainter.height * 1.7 - (minTargetValue! - lowerBound) / normalizedHeight,
            ),
            targetAreaPaint
        );
      }
    }

    if (initialData.isNotEmpty) {

      final data = Path()
        ..moveTo(
            left + (initialData.first.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (initialData.first.dy - lowerBound) / normalizedHeight
        );

      final areaData = Path()
        ..moveTo(
            left + (initialData.first.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (initialData.first.dy - lowerBound) / normalizedHeight
        );
      final center = Offset(
        left + (initialData.first.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
        size.height - verticalAxisMaxValuePainter.height * 1.7 - (initialData.first.dy - lowerBound) / normalizedHeight,
      );
      canvas.drawCircle(center, 3, circlePaint);


      double cumulativeSum = 0;
      initialData.forEach((dataPoint) {
        if(isCumulative) {
          cumulativeSum += dataPoint.dy;
          data.lineTo(
            left + (dataPoint.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (cumulativeSum - lowerBound) / normalizedHeight,
          );

          areaData.lineTo(
            left + (dataPoint.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (cumulativeSum - lowerBound) / normalizedHeight,
          );
          final center = Offset(
            left + (dataPoint.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (cumulativeSum - lowerBound) / normalizedHeight,
          );

          canvas.drawCircle(center, 3, circlePaint);

          if (dataPoint == initialData.last) {
            final TextSpan metricValueSpan = TextSpan(
              text: valuesFormat(cumulativeSum),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            );

            final TextPainter metricValuePainter = TextPainter(
              text: metricValueSpan,
              textAlign: TextAlign.left,
              textDirection: ui.TextDirection.ltr,
            );

            metricValuePainter.layout();
            metricValuePainter.paint(
              canvas,
              center -
                  Offset(metricValuePainter.width / 2.0, metricValuePainter.height * 1.5),
            );
          }

        } else {

          data.lineTo(
            left + (dataPoint.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (dataPoint.dy - lowerBound) / normalizedHeight,
          );
          areaData.lineTo(
            left + (dataPoint.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (dataPoint.dy - lowerBound) / normalizedHeight,
          );
          final center = Offset(
            left + (dataPoint.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
            size.height - verticalAxisMaxValuePainter.height * 1.7 - (dataPoint.dy - lowerBound) / normalizedHeight,
          );

          canvas.drawCircle(center, 3, circlePaint);

          if (dataPoint == initialData.last) {
            final TextSpan metricValueSpan = TextSpan(
              text: valuesFormat(dataPoint.dy),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            );

            final TextPainter metricValuePainter = TextPainter(
              text: metricValueSpan,
              textAlign: TextAlign.left,
              textDirection: ui.TextDirection.ltr,
            );

            metricValuePainter.layout();
            metricValuePainter.paint(
              canvas,
              center -
                  Offset(metricValuePainter.width / 2.0, metricValuePainter.height * 1.5),
            );
          }

        }
      });

      if(fillArea) {
        areaData.lineTo(
          left + (initialData.last.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
          size.height - verticalAxisMaxValuePainter.height * (showZeroAxis ? 1.7 : 1),
        );
        areaData.lineTo(
          left + (initialData.first.dx.millisecondsSinceEpoch - (minDateTime == null ? initialData.first.dx.millisecondsSinceEpoch : minDateTime!.millisecondsSinceEpoch)) / normalizedWidth,
          size.height - verticalAxisMaxValuePainter.height * (showZeroAxis ? 1.7 : 1),
        );
        areaData.close();

        canvas.drawPath(areaData, areaPaint);
      }

      canvas.drawPath(data, linePaint);

    }

    if (showZeroAxis) {
      canvas.drawPath(horizontalAxis, axisPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class HavkaLineChart extends StatefulWidget {
  final List<DataPoint> initialData;
  final double? minTargetValue;
  final double? maxTargetValue;
  final double? targetValue;
  final String? targetLabel;
  final bool showZeroAxis;
  final bool showTime;
  final bool isCumulative;
  final bool fillArea;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;
  final Function(num) valuesFormat;

  static String defaultValuesFormat(num _) => _.toStringAsFixed(0);

  const HavkaLineChart({
    required this.initialData,
    this.minTargetValue,
    this.maxTargetValue,
    this.targetValue,
    this.targetLabel,
    this.showZeroAxis = false,
    this.showTime = false,
    this.isCumulative = false,
    this.fillArea = false,
    this.minDateTime,
    this.maxDateTime,
    this.valuesFormat = defaultValuesFormat,
  });


  @override
  _HavkaLineChartState createState() => _HavkaLineChartState();
}


class _HavkaLineChartState extends State<HavkaLineChart> {

  late List<DataPoint> data;

  @override
  void initState() {
    super.initState();
    data = widget.initialData;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HavkaLineChartPainter(
          initialData: data,
          minTargetValue: widget.minTargetValue,
          maxTargetValue: widget.maxTargetValue,
          targetValue: widget.targetValue,
          targetLabel: widget.targetLabel,
          showZeroAxis: widget.showZeroAxis,
          showTime: widget.showTime,
          isCumulative: widget.isCumulative,
          fillArea: widget.fillArea,
          minDateTime: widget.minDateTime,
          maxDateTime: widget.maxDateTime,
          valuesFormat: widget.valuesFormat,
      ),
      child: Container(),
    );
  }

  @override
  void didUpdateWidget(covariant HavkaLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    Function eq = const ListEquality().equals;
    if(eq(widget.initialData, oldWidget.initialData)) {
      return;
    }
    if(widget.initialData.length < oldWidget.initialData.length) {
      data = List.from(widget.initialData);
      setState(() {});
      return;
    }
    if(widget.initialData.reduce((value, element) => value).dx != oldWidget.initialData.reduce((value, element) => value).dx) {
      data = List.from(widget.initialData);
      setState(() {});
      return;
    }
    final DataPoint oldLastElem = oldWidget.initialData.reduce((value, element) => value.dx.isAfter(element.dx) ? value : element);
    final oldData = oldWidget.initialData;
    final newData = widget.initialData;
    final newElements = newData.where((element) => !oldData.contains(element)).toList();
    final dataIsNew = newElements.isEmpty ? false : newElements.map((e) => e.dx.isAfter(oldLastElem.dx) ? 1 : 0).reduce(min) == 1 ? true : false;
    final int milliseconds = 30;
    if(dataIsNew) {
      final newElem = newElements.last;
      DateTime tempDx = oldLastElem.dx;
      double tempDy = (widget.isCumulative ? 0 : oldLastElem.dy);
      Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
        if(newElem.dx.difference(tempDx) < Duration(minutes: 5)) {
          data = List.from(widget.initialData);
          setState(() {});
          timer.cancel();
          return;
        }
        final tempDxSinceEpoch = tempDx.millisecondsSinceEpoch + (newElem.dx.difference(tempDx)).inMilliseconds/milliseconds*5;
        tempDx = DateTime.fromMillisecondsSinceEpoch(tempDxSinceEpoch.toInt());
        tempDy += (newElem.dy - tempDy)/milliseconds*5;
        data = List.from(oldWidget.initialData);
        data.add(DataPoint(tempDx, tempDy));
        setState(() {});
      });
    }
  }
}
