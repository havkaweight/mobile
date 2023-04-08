import 'dart:ui';

import 'package:health_tracker/constants/colors.dart';

class BarChartModel {
  String? year;
  double? metric;
  final Color color;

  BarChartModel({
    this.year,
    this.metric,
    this.color = HavkaColors.green,
  });
}
