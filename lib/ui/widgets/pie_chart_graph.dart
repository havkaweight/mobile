import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:health_tracker/model/pie_chart.dart';

class PieChart extends StatefulWidget {

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {

  @override
  Widget build(BuildContext context) {

    final List<PieChartModel> listMetric = [
      PieChartModel(year: "Protein", metric: 0.5, color: HavkaColors.green),
      PieChartModel(year: "Fats", metric: 0.3, color: HavkaColors.bone),
      PieChartModel(year: "Carbs", metric: 0.2, color: HavkaColors.green)
    ];

    final List<charts.Series<PieChartModel, String>> data = [
      charts.Series(
        id: "Metric",
        data: listMetric,
        domainFn: (PieChartModel data, _) => data.year,
        measureFn: (PieChartModel data, _) => data.metric,
        colorFn: (PieChartModel data, _) => charts.Color(r: data.color.red, g: data.color.green, b: data.color.blue),
      )
    ];

    return Expanded(
      child: charts.PieChart(data, animate: true),
    );

  }
}
