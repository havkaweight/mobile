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
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleButton(text: '1d'),
                  CircleButton(text: '7d'),
                  CircleButton(text: '30d'),
                ]
              ),
              BarChart(),
              PieChart()
            ],
          ),
        ),);
  }
}
