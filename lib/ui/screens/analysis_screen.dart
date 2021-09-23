import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/ui/widgets/bar_chart_graph.dart';
import 'package:health_tracker/ui/widgets/circle_button.dart';
import 'package:health_tracker/ui/widgets/pie_chart_graph.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String datePart;

  @override
  void initState() {
    super.initState();
    datePart = 'month';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleButton(
                text: 'd',
                onPressed: () {
                  setState(() {
                    datePart = 'day';
                  });
                },
              ),
              CircleButton(
                text: 'm',
                onPressed: () {
                  setState(() {
                    datePart = 'month';
                  });
                },
              ),
            ]),
            BarChart(
              datePart: datePart,
            ),
            PieChart()
          ],
        ),
      ),
    );
  }
}
