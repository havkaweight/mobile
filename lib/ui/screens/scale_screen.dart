import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

import 'authorization.dart';
import 'devices_screen.dart';

class ScaleScreen extends StatefulWidget {
  final UserProduct userProduct;
  final UserDevice userDevice;

  const ScaleScreen({this.userProduct, this.userDevice});

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  double weight = 0.0;

  var _subscription;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (Timer t) {});
  }

  @override
  void dispose() {
    super.dispose();
    // _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    QualifiedCharacteristic characteristic;

    final Uuid serviceUuid = Uuid.parse(Scale.serviceUuid);
    final Uuid characteristicId = Uuid.parse(Scale.characteristicId);

    characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicId,
        deviceId: '7C:9E:BD:F4:5B:1A');

    _subscription = flutterReactiveBle.readCharacteristic(characteristic).then(
        (valueArray) {
      final buffer = StringBuffer();
      for (final int element in valueArray) {
        buffer.write(String.fromCharCode(element));
      }
      final String valueString = buffer.toString();
      weight = double.parse(valueString);
      print(weight);
    }, onError: (Object error) {});

    final double protein = widget.userProduct.protein * weight / 100;
    final double fats = widget.userProduct.fat * weight / 100;
    final double carbs = widget.userProduct.carbs * weight / 100;
    final double kcal = widget.userProduct.kcal * weight / 100;
    return FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1), () {
          setState(() {});
        }),
        builder: (context, snapshot) {
          return Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ScreenSubHeader(text: widget.userProduct.productName),
                      ScreenSubHeader(text: widget.userProduct.productBrand),
                      ScreenHeader(text: '$weight g'),
                      HavkaText(
                          text: 'Protein: ${protein.toStringAsFixed(2)} g'),
                      HavkaText(text: 'Fats: ${fats.toStringAsFixed(2)} g'),
                      HavkaText(text: 'Carbs: ${carbs.toStringAsFixed(2)} g'),
                      HavkaText(text: '${kcal.toStringAsFixed(2)} kcal'),
                      RoundedButton(
                        text: 'Save',
                        onPressed: () {
                          _apiRoutes.addUserProductWeighting(
                              widget.userProduct, widget.userDevice, weight);
                          Navigator.pop(context);
                        },
                      )
                    ]),
              ));
        });
  }
}
