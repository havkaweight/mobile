import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/methods.dart';
import '../../model/pie_chart.dart';
import '../../model/user_product.dart';
import '../../ui/widgets/progress_indicator.dart';

class PieChart extends StatefulWidget {

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {

  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<UserProduct>>(
      future: _apiRoutes.getUserProductsList(),
      builder: (BuildContext context, AsyncSnapshot<List<UserProduct>> snapshot) {
        if (!snapshot.hasData) {
          return const HavkaProgressIndicator();
        } else {
          final List<PieChartModel> listMetric = [];
          for (final UserProduct userProduct in snapshot.data!) {
            // listMetric.add(PieChartModel(
                // year: userProduct.productName, metric: userProduct.protein));
            listMetric.add(PieChartModel(year: userProduct.productName, metric: userProduct.fat));
            // listMetric.add(PieChartModel(year: userProduct.productName, metric: userProduct.carbs));
          }

          final List<charts.Series<PieChartModel, String>> data = [
            charts.Series(
              id: "Metric",
              data: listMetric,
              domainFn: (PieChartModel data, _) => data.year!,
              measureFn: (PieChartModel data, _) => data.metric,
              colorFn: (PieChartModel data, _) =>
                  charts.Color(r: data.color.red,
                      g: data.color.green,
                      b: data.color.blue),

            )
          ];

          return Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [charts.PieChart(
                data,
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcWidth: 60,
                  arcRendererDecorators: [charts.ArcLabelDecorator()],),
              ),
            ]),
          );
        }
      },
    );

  }
}
