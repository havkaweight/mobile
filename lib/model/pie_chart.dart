import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import '../constants/colors.dart';

class PieChartModel {
  String year;
  double metric;
  final Color color;

  PieChartModel({
    this.year,
    this.metric,
    this.color = HavkaColors.green,
  });
}