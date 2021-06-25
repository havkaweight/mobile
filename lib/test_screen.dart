import 'package:flutter/material.dart';
import 'package:health_tracker/widgets/screen_header.dart';
import 'widgets/rounded_button.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:health_tracker/components/chart.dart';
import 'dart:ui';
import 'dart:math';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Chart> data;
  var r = Random();
  @override
  void initState() {
    super.initState();
    data = [
      Chart(
          name: 'Food',
          value: r.nextInt(2000) * 1.0,
          color: charts.ColorUtil.fromDartColor(Color(0xFF5BBE78))
      ),
      Chart(
          name: 'Non-Food',
          value: r.nextInt(2000) * 1.0,
          color: charts.ColorUtil.fromDartColor(Color(0xFFACBE78))
      )
    ];
  }

  @override
  Widget build (BuildContext context) {
    List<charts.Series<Chart, String>> series = [
      charts.Series(
        id: 'Label',
        data: data,
        domainFn: (Chart series, _) => series.name,
        measureFn: (Chart series, _) => series.value,
        colorFn: (Chart series, _) => series.color
      )
    ];
    final dataValues = data.map((x) => x.value);
    final String val = (dataValues.first/dataValues.reduce((a, b) => a + b) * 100).toStringAsFixed(0);
    return Scaffold (
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ScreenHeader(
                  text: 'Test charts'
                ),
                ScreenSubHeader(
                    text: 'charts_flutter'
                ),
                RoundedButton(
                  text: 'Test',
                  color: Color(0xFF5BBE78),
                  onPressed: () {
                    setState(() {
                      data = [
                        Chart(
                          name: 'Food',
                          value: r.nextInt(2000) * 1.0,
                          color: charts.ColorUtil.fromDartColor(Color(0xFF5BBE78))
                        ),
                        Chart(
                          name: 'Non-Food',
                          value: r.nextInt(2000) * 1.0,
                          color: charts.ColorUtil.fromDartColor(Color(0xFFACBE78))
                        )
                      ];
                    });
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
                  },
                ),
                Container(
                  height: 200,
                  child: Stack(
                    children: <Widget>[
                      charts.PieChart(
                        series,
                        defaultRenderer: charts.ArcRendererConfig(
                          arcWidth: 10,
                          arcRendererDecorators: [charts.ArcLabelDecorator(
                            labelPosition: charts.ArcLabelPosition.inside
                          )]
                        ),
                        animate: true
                      ),
                      Center(
                        child: Text(
                        '$val%',
                          style: TextStyle(
                              fontSize: 30.0,
                              color: Color(0xFF5BBE78),
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                    ]
                  ),
                )
              ])
          ),
        )
    );
  }
}