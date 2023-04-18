import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/constants/utils.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

class ScaleScreen extends StatefulWidget {
  final UserProduct? userProduct;
  final UserDevice? userDevice;

  const ScaleScreen({this.userProduct, this.userDevice});

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  double? weight;
  double? protein;
  double? fats;
  double? carbs;
  double? kcal;

  String prevText = '';
  final weightController = TextEditingController();
  late dynamic _subscription;

  void _changeNutritionValues() {
    if (weightController.text.isNotEmpty) {
      if (prevText != weightController.text) {
        prevText = weightController.text;
        weight = double.parse(weightController.text);
      }
    } else {
      weight = 0.0;
    }
    setState(() {});
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
      deviceId: '7C:9E:BD:F4:5B:1A',
    );

    protein = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.protein!
        : 0 * weight! / 100;
    fats = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.fat!
        : 0 * weight! / 100;
    carbs = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.carbs!
        : 0 * weight! / 100;
    kcal = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.kcal!
        : 0 * weight! / 100;

    // _subscription = flutterReactiveBle
    //     .readCharacteristic(scaleCharacteristic)
    //     .then((valueList) {
    //   final String valueString = utils.listIntToString(valueList);
    //   weight = double.parse(valueString);
    //   print(weight);
    // }, onError: (Object error) {});

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
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
            children: [
              ScreenSubHeader(text: widget.userProduct!.product!.name!),
              // ScreenSubHeader(text: widget.userProduct!.product!.brand ?? '-'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: RoundedTextField(
                      width: 100,
                      controller: weightController,
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  Text(
                    widget.userProduct!.amount != null
                        ? widget.userProduct!.amount!.unit
                        : ' g',
                  )
                ],
              ),
              Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(
                    children: [
                      const Text('Protein '),
                      Text(
                        protein!.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        widget.userProduct!.amount != null
                            ? widget.userProduct!.amount!.unit
                            : ' g',
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Fats '),
                      Text(
                        fats!.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        widget.userProduct!.amount != null
                            ? widget.userProduct!.amount!.unit
                            : ' g',
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Carbs '),
                      Text(
                        carbs!.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        widget.userProduct!.amount != null
                            ? widget.userProduct!.amount!.unit
                            : ' g',
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Calories '),
                      Text(
                        kcal!.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const Text(' kcal')
                    ],
                  )
                ],
              ),
              RoundedButton(
                text: 'Save',
                onPressed: () {
                  _apiRoutes.addUserConsumptionItem(
                      userProduct: widget.userProduct!, netWeight: weight!);
                  Navigator.pop(context);
                },
              )
            ],
          ),
          // })
        ),
      ),
    );
  }
}
