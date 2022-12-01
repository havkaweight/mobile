import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../api/methods.dart';
import '../../constants/scale.dart';
import '../../constants/utils.dart';
import '../../model/user_device.dart';
import '../../model/user_product.dart';
import '../../ui/widgets/rounded_button.dart';
import '../../ui/widgets/rounded_textfield.dart';
import '../../ui/widgets/screen_header.dart';

class ScaleScreen extends StatefulWidget {
  final UserProduct userProduct;
  final UserDevice userDevice;

  const ScaleScreen({this.userProduct, this.userDevice});

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  double weight;
  double protein;
  double fats;
  double carbs;
  double kcal;

  String prevText = '';
  final weightController = TextEditingController();
  dynamic _subscription;

  void _changeNutritionValues() {
    if (weightController.text.isNotEmpty) {
      if (prevText != weightController.text) {
        prevText = weightController.text;
        weight = double.parse(weightController.text);
      }
    } else {
      weight = 0.0;
    }
    setState((){});
  }

  @override
  void initState() {
    super.initState();

    weight = 0.0;
    protein = 0.0;
    fats = 0.0;
    carbs = 0.0;
    kcal = 0.0;

    weightController.addListener(_changeNutritionValues);
  }


  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
    // _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    QualifiedCharacteristic scaleCharacteristic;
    final Utils utils = Utils();

    final Uuid scaleServiceUuid = Uuid.parse(Scale.scaleServiceUuid);
    final Uuid scaleCharacteristicId = Uuid.parse(Scale.scaleCharacteristicId);

    scaleCharacteristic = QualifiedCharacteristic(
        serviceId: scaleServiceUuid,
        characteristicId: scaleCharacteristicId,
        deviceId: '7C:9E:BD:F4:5B:1A');

    protein = widget.userProduct.protein * weight / 100;
    fats = widget.userProduct.fat * weight / 100;
    carbs = widget.userProduct.carbs * weight / 100;
    kcal = widget.userProduct.kcal * weight / 100;

    // _subscription = flutterReactiveBle
    //     .readCharacteristic(scaleCharacteristic)
    //     .then((valueList) {
    //   final String valueString = utils.listIntToString(valueList);
    //   weight = double.parse(valueString);
    //   print(weight);
    // }, onError: (Object error) {});

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
            child:
            // StreamBuilder<List<int>>(
            //     stream: flutterReactiveBle
            //         .subscribeToCharacteristic(scaleCharacteristic),
            //     builder:
            //         (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            //       if (!snapshot.hasData) {
            //         print(weight);
            //       } else {
            //         final String valueString =
            //             utils.listIntToString(snapshot.data);
            //         weight = double.parse(valueString);
            //       }
            //       weightController.text = '$weight';
            //       final protein = widget.userProduct.protein * weight / 100;
            //       final fats = widget.userProduct.fat * weight / 100;
            //       final carbs = widget.userProduct.carbs * weight / 100;
            //       final kcal = widget.userProduct.kcal * weight / 100;
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ScreenSubHeader(text: widget.userProduct.productName),
                        ScreenSubHeader(text: widget.userProduct.productBrand),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RoundedTextField(
                                width: 0.5,
                                controller: weightController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                            ),
                            Text(widget.userProduct.unit)
                          ],
                        ),
                        Table(
                          defaultColumnWidth: const IntrinsicColumnWidth(),
                          children: [
                            TableRow(children: [
                              const Text('Protein '),
                              Text(
                                protein.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              Text(' ${widget.userProduct.unit}')
                            ]),
                            TableRow(children: [
                              const Text('Fats '),
                              Text(
                                fats.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              Text(' ${widget.userProduct.unit}')
                            ]),
                            TableRow(children: [
                              const Text('Carbs '),
                              Text(
                                carbs.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              Text(' ${widget.userProduct.unit}')
                            ]),
                            TableRow(children: [
                              const Text('Calories '),
                              Text(
                                kcal.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const Text(' kcal')
                            ])
                          ],
                        ),
                        RoundedButton(
                          text: 'Save',
                          onPressed: () {
                            _apiRoutes.addUserProductWeighting(
                              weight,
                              widget.userProduct,
                              // userDevice: widget.userDevice,
                            );
                            Navigator.pop(context);
                          },
                        )
                      ])
                // })
  ));
  }
}
