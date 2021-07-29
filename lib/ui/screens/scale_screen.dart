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
  }

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _apiRoutes.getMe(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        const weight = 69;
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