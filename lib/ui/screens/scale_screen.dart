import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

class ScaleScreen extends StatefulWidget {
  final UserProduct userProduct;

  const ScaleScreen({
    this.userProduct
  });

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  int weight = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (Timer t) {});
  }

  @override
  Widget build(BuildContext context) {
    // stream.listen((connectionState) {
    //     weight = flutterReactiveBle.readCharacteristic(characteristic);
    //   }, onError: (Object error){
    //   });
    final double protein = (widget.userProduct.protein != null) ? widget.userProduct.protein : 0 * weight / 100;
    final double fats = (widget.userProduct.fat != null) ? widget.userProduct.fat : 0 * weight / 100;
    final double carbs = (widget.userProduct.carbs != null) ? widget.userProduct.carbs : 0 * weight / 100;
    final double kcal = (widget.userProduct.kcal != null) ? widget.userProduct.kcal : 0 * weight / 100;
    return FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1), () {
              setState((){weight += 1;});
            }),
        builder: (context, snapshot) {
          return Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    ScreenHeader(text: widget.userProduct.productName),
                    ScreenSubHeader(text: widget.userProduct.productBrand),
                    ScreenHeader(text: '$weight g'),
                    ScreenSubHeader(text: 'Protein: $protein g'),
                    ScreenSubHeader(text: 'Fats: $fats g'),
                    ScreenSubHeader(text: 'Carbs: $carbs g'),
                    ScreenSubHeader(text: '$kcal kcal'),
                    // RoundedButton(
                    //   text: 'OK',
                    //   onPressed: () {
                    //     Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
                    //   },
                    // )
                  ])));
        });
  }
}
