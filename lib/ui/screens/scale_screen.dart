import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

class ScaleScreen extends StatefulWidget {
  final UserProduct product;

  const ScaleScreen({
    this.product
  });

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();

    // data = [
    //   Chart(
    //     name: 'Protein',
    //     value: widget.product.protein,
    //     color: charts.ColorUtil.fromDartColor(Color(0xFF5BBE78))
    //   ),
    //   Chart(
    //     name: 'Fat',
    //     value: widget.product.fat,
    //     color: charts.ColorUtil.fromDartColor(Color(0xFFACBE78))
    //   ),
    //   Chart(
    //       name: 'Carbs',
    //       value: widget.product.carbs,
    //       color: charts.ColorUtil.fromDartColor(Color(0xFFACBE78))
    //   )
    // ];
  }

  @override
  Widget build (BuildContext context) {
    // Random random = new Random();
    // double weight = (100 + random.nextInt(900)) / 10;

    // List<charts.Series<Chart, String>> series = [
    //   charts.Series(
    //       id: 'Label',
    //       data: data,
    //       domainFn: (Chart series, _) => series.name,
    //       measureFn: (Chart series, _) => series.value,
    //       colorFn: (Chart series, _) => series.color
    //   )
    // ];
    // final dataValues = data.map((x) => x.value);
    // final String val = (dataValues.first/dataValues.reduce((a, b) => a + b) * 100).toStringAsFixed(0);

    return FutureBuilder(
      future: _apiRoutes.getMe(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        const weight = 0;
        // stream.listen((connectionState) {
        //     weight = flutterReactiveBle.readCharacteristic(characteristic);
        //   }, onError: (Object error){
        //   });
        return Scaffold (
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ScreenHeader(
              text: '$weight g'
            ),
            RoundedButton(
              text: 'OK',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
              },
            )
          ])
      )
    );
      }
    );
  }
}