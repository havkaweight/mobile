import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/methods.dart';
import '../../model/bar_chart.dart';
import '../../model/user_product_weighting.dart';
import '../../ui/widgets/progress_indicator.dart';

class BarChart extends StatefulWidget {
  final String datePart;
  const BarChart({this.datePart = 'month'});

  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProductWeighting>>(
      future: _apiRoutes.getWeightingsHistory(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<UserProductWeighting>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const HavkaProgressIndicator();
        } else {
          final List<BarChartModel> listMetric = [];
          DateFormat formatter = DateFormat('yy-MM-dd');
          if (widget.datePart == 'month') {
            formatter = DateFormat('yy-MM');
          } else if (widget.datePart == 'day') {
            formatter = DateFormat('yy-MM-dd');
          }
          final userProductWeightingList = snapshot.data;
          userProductWeightingList!
              .sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
          for (final UserProductWeighting userProductWeighting
              in userProductWeightingList) {
            listMetric.add(
              BarChartModel(
                year: formatter.format(userProductWeighting.createdAt!),
                metric: userProductWeighting.userProductWeight,
              ),
            );
          }

          final List<charts.Series<BarChartModel, String>> timeline = [
            charts.Series(
              id: "Weightings history",
              data: listMetric,
              domainFn: (BarChartModel timeline, _) => timeline.year!,
              measureFn: (BarChartModel timeline, _) => timeline.metric,
              colorFn: (BarChartModel timeline, _) => charts.Color(
                r: timeline.color.red,
                g: timeline.color.green,
                b: timeline.color.blue,
              ),
              labelAccessorFn: (BarChartModel timeline, _) =>
                  timeline.metric.toString(),
            )
          ];

          return Expanded(
            child: charts.BarChart(
              timeline,
              animate: true,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
            ),
          );
        }
      },
    );
  }
}
