import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/constants/utils.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/utils/utils.dart';

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
  late DateTime selectedDateTime;

  String prevText = '';
  final FocusNode _weightFocusNode = FocusNode();
  final TextEditingController weightController = TextEditingController();
  String? weightError;
  late dynamic _subscription;

  void _onFocusWeight() {
    if (_weightFocusNode.hasFocus) {
      setState(() => weightError = null);
    }
  }

  void _changeNutritionValues() {
    if (weightController.text.isNotEmpty) {
      if (prevText != weightController.text) {
        String newText = weightController.text;
        if (newText.contains(',')) {
          newText = newText.replaceAll(',', '.');
          weightController.text = weightController.text.replaceAll(',', '.');
          weightController.selection = TextSelection.fromPosition(
            TextPosition(offset: weightController.text.length),
          );
        }
        prevText = newText;
        weight = double.parse(newText);
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
    selectedDateTime = DateTime.now();

    weightController.addListener(_changeNutritionValues);
    weightController.addListener(_onFocusWeight);
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
        ? widget.userProduct!.product!.nutrition!.protein! * weight! / 100.0
        : 0;
    fats = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.fat! * weight! / 100
        : 0;
    carbs = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.carbs! * weight! / 100
        : 0;
    kcal = widget.userProduct!.product!.nutrition != null &&
            widget.userProduct!.product!.nutrition!.energy != null
        ? widget.userProduct!.product!.nutrition!.energy!.first.value *
            weight! /
            100
        : 0;

    // _subscription = flutterReactiveBle
    //     .readCharacteristic(scaleCharacteristic)
    //     .then((valueList) {
    //   final String valueString = utils.listIntToString(valueList);
    //   weight = double.parse(valueString);
    //   print(weight);
    // }, onError: (Object error) {});

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: SafeArea(
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
                  Hero(
                    tag: 'userProductImage-${widget.userProduct!.id}',
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 300,
                        height: 300,
                        margin: const EdgeInsets.only(bottom: 30.0),
                        decoration: BoxDecoration(
                          color: const Color(0xff7c94b6),
                          image: widget.userProduct!.product!.img != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    widget.userProduct!.product!.img!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50.0)),
                        ),
                      ),
                    ),
                  ),
                  ScreenSubHeader(text: widget.userProduct!.product!.name!),
                  // ScreenSubHeader(text: widget.userProduct!.product!.brand ?? '-'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: RoundedTextField(
                          errorText: weightError,
                          focusNode: _weightFocusNode,
                          width: 100,
                          controller: weightController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d+)?[\.\,]?\d{0,2}'),
                            )
                          ],
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
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(
                              FontAwesomeIcons.dna,
                              size: 12,
                              color: HavkaColors.protein,
                            ),
                          ),
                          const Text(
                            'Protein ',
                            style: TextStyle(
                              color: HavkaColors.protein,
                            ),
                          ),
                          Text(
                            protein!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HavkaColors.protein,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            widget.userProduct!.amount != null
                                ? ' ${widget.userProduct!.amount!.unit}'
                                : ' g',
                            style: const TextStyle(
                              color: HavkaColors.protein,
                            ),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(
                              FontAwesomeIcons.droplet,
                              size: 12,
                              color: HavkaColors.fat,
                            ),
                          ),
                          const Text(
                            'Fat ',
                            style: TextStyle(
                              color: HavkaColors.fat,
                            ),
                          ),
                          Text(
                            fats!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HavkaColors.fat,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            widget.userProduct!.amount != null
                                ? ' ${widget.userProduct!.amount!.unit}'
                                : ' g',
                            style: const TextStyle(
                              color: HavkaColors.fat,
                            ),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(
                              FontAwesomeIcons.wheatAwn,
                              size: 12,
                              color: HavkaColors.carbs,
                            ),
                          ),
                          const Text(
                            'Carbs ',
                            style: TextStyle(
                              color: HavkaColors.carbs,
                            ),
                          ),
                          Text(
                            carbs!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HavkaColors.carbs,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            widget.userProduct!.amount != null
                                ? ' ${widget.userProduct!.amount!.unit}'
                                : ' g',
                            style: const TextStyle(
                              color: HavkaColors.carbs,
                            ),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          for (int i = 0; i < 4; i++)
                            Container(
                              height: 20,
                            )
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(
                              FontAwesomeIcons.utensils,
                              size: 12,
                              color: HavkaColors.kcal,
                            ),
                          ),
                          const Text(
                            'Calories ',
                            style: TextStyle(
                              color: HavkaColors.kcal,
                            ),
                          ),
                          Text(
                            kcal!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HavkaColors.kcal,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const Text(
                            ' kcal',
                            style: TextStyle(
                              color: HavkaColors.kcal,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                        ),
                        context: context,
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.5,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CupertinoDatePicker(
                                  use24hFormat: true,
                                  initialDateTime: DateTime.now(),
                                  minimumDate: DateTime.now()
                                      .subtract(const Duration(days: 365)),
                                  maximumDate: DateTime.now(),
                                  onDateTimeChanged: (value) {
                                    setState(() {
                                      selectedDateTime = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(formatDate(selectedDateTime)),
                  ),
                  RoundedButton(
                    text: 'Save',
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (weightController.text.isEmpty) {
                        setState(() {
                          weightError = 'Empty weight';
                        });
                        return;
                      }
                      _apiRoutes.addUserConsumptionItem(
                        userProduct: widget.userProduct!,
                        netWeight: weight!,
                        consumedAt: selectedDateTime,
                      );
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              // })
            ),
          ),
        ),
      ),
    );
  }
}
