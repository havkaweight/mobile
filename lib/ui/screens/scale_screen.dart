import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/constants/utils.dart';
import 'package:health_tracker/model/product_amount.dart';
import 'package:health_tracker/model/user_consumption_item.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/routes/sharp_page_route.dart';
import 'package:health_tracker/ui/screens/product_updating_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/utils/utils.dart';

class ScaleScreen extends StatefulWidget {
  final UserProduct? userProduct;
  final List<UserConsumptionItem>? userConsumption;
  final UserDevice? userDevice;

  const ScaleScreen({
    this.userProduct,
    this.userConsumption,
    this.userDevice,
  });

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
        ? widget.userProduct!.product!.nutrition!.protein! * weight! / 100
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
            child: Align(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Hero(
                              tag: 'userProductImage-${widget.userProduct!.id}',
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child:
                                      widget.userProduct!.product!.img != null
                                          ? Container(
                                              width: 150,
                                              height: 150,
                                              decoration: BoxDecoration(
                                                color: const Color(0xff7c94b6),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    widget.userProduct!.product!
                                                        .img!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(50.0),
                                                ),
                                                border: Border.all(
                                                  width: 4.0,
                                                  color: HavkaColors.kcal,
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Container(
                                                width: 150,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(50.0),
                                                  ),
                                                  border: Border.all(
                                                    width: 4.0,
                                                    color: HavkaColors.kcal,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  FontAwesomeIcons.bowlFood,
                                                  color: HavkaColors.kcal,
                                                  size: 60,
                                                ),
                                              ),
                                            ),
                                ),
                              ),
                            ),
                            TextButton(
                              child: const Text('Edit'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductUpdatingScreen(
                                      product: widget.userProduct!.product!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Text(
                                showUsername(
                                  widget.userProduct!.product!.name!,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                      widget.userProduct!.product!.nutrition !=
                                              null
                                          ? widget.userProduct!.product!
                                              .nutrition!.protein
                                              .toString()
                                          : '-',
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
                                      widget.userProduct!.product!.nutrition !=
                                              null
                                          ? widget.userProduct!.product!
                                              .nutrition!.fat
                                              .toString()
                                          : '-',
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
                                      widget.userProduct!.product!.nutrition !=
                                              null
                                          ? widget.userProduct!.product!
                                              .nutrition!.carbs
                                              .toString()
                                          : '-',
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
                                      widget.userProduct!.product!.nutrition !=
                                              null
                                          ? widget.userProduct!.product!
                                              .nutrition!.energy!.first.value
                                              .toString()
                                          : '-',
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: HavkaColors.bone[100],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'Grab your portion here',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: RoundedTextField(
                      errorText: weightError,
                      focusNode: _weightFocusNode,
                      width: 100,
                      controller: weightController,
                      textAlign: TextAlign.center,
                      suffixText: widget.userProduct!.amount != null
                          ? widget.userProduct!.amount!.unit
                          : 'g',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?[\.\,]?\d{0,2}'),
                        ),
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              FontAwesomeIcons.dna,
                              size: 12,
                              color: HavkaColors.protein,
                            ),
                          ),
                          Text(
                            protein!.toStringAsFixed(1),
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
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              FontAwesomeIcons.droplet,
                              size: 12,
                              color: HavkaColors.fat,
                            ),
                          ),
                          Text(
                            fats!.toStringAsFixed(1),
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
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              FontAwesomeIcons.wheatAwn,
                              size: 12,
                              color: HavkaColors.carbs,
                            ),
                          ),
                          Text(
                            carbs!.toStringAsFixed(1),
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
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              FontAwesomeIcons.utensils,
                              size: 12,
                              color: HavkaColors.kcal,
                            ),
                          ),
                          Text(
                            kcal!.toStringAsFixed(1),
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
                    child: SizedBox(
                      width: 180,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                CupertinoIcons.calendar,
                                // FontAwesomeIcons.calendar,
                                size: 22,
                              ),
                            ),
                            Text(
                              formatDate(selectedDateTime),
                            ),
                          ]),
                    ),
                  ),
                  RoundedButton(
                    text: 'Add',
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (weightController.text.isEmpty) {
                        setState(() {
                          weightError = 'Empty weight';
                        });
                        return;
                      }
                      final UserConsumptionItem userConsumptionItem =
                          UserConsumptionItem(
                        userProduct: widget.userProduct,
                        amount: ProductAmount(value: weight!, unit: 'g'),
                        consumedAt: selectedDateTime,
                      );
                      _apiRoutes.addUserConsumptionItem(
                          userConsumptionItem: userConsumptionItem);
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: HavkaColors.bone[100],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'Consumption History',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  if (widget.userConsumption!.isNotEmpty)
                    SizedBox(
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ListView.builder(
                          itemCount: widget.userConsumption!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final List<UserConsumptionItem> _userConsumption =
                                widget.userConsumption!;
                            _userConsumption.sort(
                              (prev, next) =>
                                  (next.consumedAt ?? next.createdAt!)
                                      .compareTo(
                                prev.consumedAt ?? prev.createdAt!,
                              ),
                            );
                            final UserConsumptionItem userConsumptionItem =
                                _userConsumption[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${userConsumptionItem.amount!.value} ${userConsumptionItem.amount!.unit}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                  ),
                                  Text(
                                    formatDate(
                                      userConsumptionItem.consumedAt ??
                                          userConsumptionItem.createdAt!,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    const Center(child: Text('No history found')),
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
