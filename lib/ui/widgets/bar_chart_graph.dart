import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:health_tracker/model/user_product_weighting.dart';
import 'package:intl/intl.dart';

class BarChart extends StatefulWidget {

  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProductWeighting>>(
      future: _apiRoutes.getWeightingsHistory(),
      builder: (BuildContext context, AsyncSnapshot<List<UserProductWeighting>> snapshot) {
        final List<BarChartModel> listMetric = [];
        final DateFormat formatter = DateFormat('yy-MM-dd');
        final userProductWeightingList = snapshot.data;
        userProductWeightingList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        for (final UserProductWeighting userProductWeighting in userProductWeightingList) {
          listMetric.add(BarChartModel(year: formatter.format(userProductWeighting.createdAt), metric: userProductWeighting.userProductWeight));
        }

        // final List<BarChartModel> listMetric = [
        //   BarChartModel(year: "2017", metric: 93),
        //   BarChartModel(year: "2018", metric: 108),
        //   BarChartModel(year: "2019", metric: 109),
        //   BarChartModel(year: "2020", metric: 117),
        //   BarChartModel(year: "2021", metric: 120),
        // ];

        final List<charts.Series<BarChartModel, String>> timeline = [
          charts.Series(
            id: "Weightings history",
            data: listMetric,
            domainFn: (BarChartModel timeline, _) => timeline.year,
            measureFn: (BarChartModel timeline, _) => timeline.metric,
            colorFn: (BarChartModel timeline, _) => charts.Color(r: timeline.color.red, g: timeline.color.green, b: timeline.color.blue),
          )
        ];

        return Expanded(
          child: charts.BarChart(timeline, animate: true),
        );
      },
    );

  }

}