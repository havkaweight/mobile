import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BarChart extends StatefulWidget {

  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {

  @override
  Widget build(BuildContext context) {

    final List<BarChartModel> listMetric = [
      BarChartModel(year: "2017", metric: 93),
      BarChartModel(year: "2018", metric: 108),
      BarChartModel(year: "2019", metric: 109),
      BarChartModel(year: "2020", metric: 117),
      BarChartModel(year: "2021", metric: 120),
    ];

    final List<charts.Series<BarChartModel, String>> timeline = [
      charts.Series(
        id: "Metric",
        data: listMetric,
        domainFn: (BarChartModel timeline, _) => timeline.year,
        measureFn: (BarChartModel timeline, _) => timeline.metric,
        colorFn: (BarChartModel timeline, _) => charts.Color(r: timeline.color.red, g: timeline.color.green, b: timeline.color.blue),
      )
    ];

    return Expanded(
      child: charts.BarChart(timeline, animate: true),
    );

  }

}