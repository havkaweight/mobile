import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

import 'authorization.dart';

class ScaleScreen extends StatefulWidget {
  final UserProduct userProduct;
  final UserDevice userDevice;

  const ScaleScreen({
    this.userProduct,
    this.userDevice
  });

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  double weight = 0.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (Timer t) {});
  }

  @override
  Widget build(BuildContext context) {

    // stream.listen((connectionState) {
    //   weight = flutterReactiveBle.readCharacteristic(characteristic);
    // }, onError: (Object error) {});

    final double protein = widget.userProduct.protein * weight / 100;
    final double fats = widget.userProduct.fat * weight / 100;
    final double carbs = widget.userProduct.carbs * weight / 100;
    final double kcal = widget.userProduct.kcal * weight / 100;
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
                    ScreenSubHeader(text: 'Protein: ${protein.toStringAsFixed(2)} g'),
                    ScreenSubHeader(text: 'Fats: ${fats.toStringAsFixed(2)} g'),
                    ScreenSubHeader(text: 'Carbs: ${carbs.toStringAsFixed(2)} g'),
                    ScreenSubHeader(text: '${kcal.toStringAsFixed(2)} kcal'),
                    RoundedButton(
                      text: 'Save',
                      onPressed: () async {
                        await _apiRoutes.addUserProductWeighting(widget.userProduct, widget.userDevice, weight);
                        Navigator.pop(context);
                      },
                    )
                  ])));
        });
  }
}
