import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/presentation/widgets/submit_button.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product/brand.dart';
import '../../domain/entities/product/carbs.dart';
import '../../domain/entities/product/energy.dart';
import '../../domain/entities/product/fat.dart';
import '../../domain/entities/product/nutrition.dart';
import '../../domain/entities/product/package.dart';
import '../../domain/entities/product/protein.dart';
import '../../domain/entities/product/serving.dart';
import '../../domain/repositories/product/product_repository.dart';
import '/core/constants/colors.dart';
import '../../domain/entities/product/product.dart';
import '/presentation/screens/havka_barcode_scanner.dart';
import '/presentation/widgets/rounded_textfield.dart';
import '/utils/formatters/comma_formatter.dart';
import '/core/constants/icons.dart';
import '/core/constants/units.dart';
import '/core/constants/utils.dart';

class ProductAdjustmentScreen extends StatefulWidget {
  final Product? product;
  final String? barcode;

  const ProductAdjustmentScreen({
    this.product,
    this.barcode,
  });

  @override
  _ProductAdjustmentScreenState createState() =>
      _ProductAdjustmentScreenState();
}

class _ProductAdjustmentScreenState extends State<ProductAdjustmentScreen>
    with TickerProviderStateMixin {
  final TextEditingController packNameController = TextEditingController();
  final TextEditingController packSizeValueController = TextEditingController();

  final List<Map<String, TextEditingController>> _servingControllers =
      <Map<String, TextEditingController>>[];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController saturatedFatController = TextEditingController();
  final TextEditingController monounsaturatedFatController = TextEditingController();
  final TextEditingController polyunsaturatedFatController = TextEditingController();
  final TextEditingController transFatController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController sugarsController = TextEditingController();
  final TextEditingController fiberController = TextEditingController();
  final TextEditingController energyValueController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final List<String> energyUnits = [EnergyUnits.kcal, EnergyUnits.kj];
  List<String> packSizeUnits = [Units.g, Units.ml];
  late String energyUnit;
  late String packSizeUnit;
  String prevText = '';

  final FocusNode packNameFocusNode = FocusNode();
  final FocusNode packSizeValueFocusNode = FocusNode();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode brandFocusNode = FocusNode();
  final FocusNode proteinFocusNode = FocusNode();
  final FocusNode fatFocusNode = FocusNode();
  final FocusNode saturatedFatFocusNode = FocusNode();
  final FocusNode monounsaturatedFatFocusNode = FocusNode();
  final FocusNode polyunsaturatedFatFocusNode = FocusNode();
  final FocusNode transFatFocusNode = FocusNode();
  final FocusNode carbsFocusNode = FocusNode();
  final FocusNode sugarsFocusNode = FocusNode();
  final FocusNode fiberFocusNode = FocusNode();
  final FocusNode energyValueFocusNode = FocusNode();
  final FocusNode energyUnitFocusNode = FocusNode();
  final FocusNode weightFocusNode = FocusNode();
  final FocusNode unitFocusNode = FocusNode();
  final FocusNode barcodeFocusNode = FocusNode();


  late final List<Widget> iconsList;

  late ScrollController _scrollController;
  GlobalKey backgroundWidgetKey = GlobalKey();
  late Offset widgetOffset;
  late double _currentPosition;
  double opacity = 1;

  late List<Serving> perServingList;
  late Serving perServing;


  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollBehaviour);

    _servingControllers.add({
      "name": TextEditingController(),
      "value": TextEditingController(),
    });

    if (widget.product?.package?.value != null) {
      final Serving? packServing = widget.product?.serving.firstWhere(
          (element) =>
              element.valueInBaseUnit == widget.product!.package!.value);
      _servingControllers[0]["name"]?.text = packServing?.name ?? "pack";
      _servingControllers[0]["value"]?.text = Utils().formatNumber(packServing!.valueInBaseUnit)!;
    } else {
      _servingControllers[0]["name"]?.text = "pack";
      _servingControllers[0]["value"]?.text = "";
    }

    if (widget.product?.serving != null && widget.product!.serving.where((element) => element.valueInBaseUnit != 1 || element.valueInBaseUnit == widget.product!.package!.value).length > 1) {
      List<Serving> _servings = widget.product!.serving.where((element) => element.valueInBaseUnit != 1 && element.valueInBaseUnit != widget.product!.package!.value).toList();
      _servings.sort((a, b) => a.valueInBaseUnit.compareTo(b.valueInBaseUnit));
      _servingControllers.addAll(_servings.map((e) => {
        "name": TextEditingController(text: e.name),
        "value": TextEditingController(text: Utils().formatNumber(e.valueInBaseUnit)),
      }));
    } else {
      _servingControllers.add({
        "name": TextEditingController(),
        "value": TextEditingController(),
      });
    }

    _servingControllers.forEach((element) {
      element["name"]?.addListener(() => setState(() {
        if(element["value"]!.text.isNotEmpty && perServing.valueInBaseUnit == double.parse(element["value"]!.text)) {
          perServing = perServingList.first;
        }
      }
      ));
      element["value"]?.addListener(() => setState(() {
        if(element["name"]!.text.isNotEmpty && perServing.name == element["name"]!.text) {
          perServing = perServingList.first;
        }
      }
      ));
    });

    perServingList = [
      Serving(name: "default", valueInBaseUnit: 100)
    ];

    if (_servingControllers.where((e) => e["name"]!.text.isNotEmpty && e["value"]!.text.isNotEmpty).length > 0) {
      perServingList.addAll(_servingControllers.where((e) => e["name"]!.text.isNotEmpty && e["value"]!.text.isNotEmpty).map((e) => Serving(name: e["name"]!.text, valueInBaseUnit: double.parse(e["value"]!.text))));
    }
    perServingList.sort((a, b) {
      if(a.valueInBaseUnit == 100) {
        return -1;
      }
      return a.valueInBaseUnit.compareTo(
          b.valueInBaseUnit);
    });
    if (widget.product != null) {
      perServing = perServingList.firstWhere((element) => element.valueInBaseUnit == widget.product!.nutrition!.valuePerInBaseUnit);
    } else {
      perServing = perServingList[0];
    }

    iconsList = List.generate(
      100,
      (_) {
        final food = [
          HavkaIcons.bowl,
          FontAwesomeIcons.pepperHot,
          FontAwesomeIcons.drumstickBite,
          FontAwesomeIcons.fish,
          FontAwesomeIcons.shrimp,
          FontAwesomeIcons.pizzaSlice,
          FontAwesomeIcons.hotdog,
          FontAwesomeIcons.carrot,
          FontAwesomeIcons.lemon,
          FontAwesomeIcons.breadSlice,
        ];
        return Icon(
          food[Random().nextInt(food.length)],
          color: Colors.grey.withValues(alpha: 0.3),
          size: 30,
        );
      },
    );

    barcodeController.text = (widget.product?.barcode == null
        ? (widget.barcode == null ? "" : widget.barcode)
        : widget.product?.barcode)!;
    nameController.text = widget.product?.name ?? '';
    brandController.text = widget.product?.brand?.name ?? '';
    proteinController.text =
        Utils().formatNumber(widget.product?.nutrition?.protein?.total) ?? '';
    fatController.text =
        Utils().formatNumber(widget.product?.nutrition?.fat?.total) ?? '';
    saturatedFatController.text =
        Utils().formatNumber(widget.product?.nutrition?.fat?.saturated) ?? '';
    monounsaturatedFatController.text =
        Utils().formatNumber(widget.product?.nutrition?.fat?.monounsaturated) ?? '';
    polyunsaturatedFatController.text =
        Utils().formatNumber(widget.product?.nutrition?.fat?.polyunsaturated) ?? '';
    transFatController.text =
        Utils().formatNumber(widget.product?.nutrition?.fat?.trans) ?? '';
    carbsController.text =
        Utils().formatNumber(widget.product?.nutrition?.carbs?.total) ?? '';
    sugarsController.text =
        Utils().formatNumber(widget.product?.nutrition?.carbs?.sugars) ?? '';
    fiberController.text =
        Utils().formatNumber(widget.product?.nutrition?.carbs?.dietaryFiber) ?? '';
    energyValueController.text =
        Utils().formatNumber(widget.product?.nutrition?.energy!.kcal) ?? '';
    packSizeValueController.text =
        Utils().formatNumber(widget.product?.package?.value) ?? '';

    energyUnit = widget.product == null
        ? EnergyUnits.kcal
        : widget.product?.nutrition?.energy?.kcal != null
            ? EnergyUnits.kcal
            : EnergyUnits.kj;

    packSizeUnits = widget.product == null
        ? packSizeUnits
        : widget.product!.baseUnit == Units.g
            ? packSizeUnits
            : packSizeUnits.reversed.toList();

    packSizeUnit = packSizeUnits.first;
  }

  _scrollBehaviour() {
    RenderBox renderBox =
        backgroundWidgetKey.currentContext?.findRenderObject() as RenderBox;
    widgetOffset = renderBox.localToGlobal(Offset.zero);
    _currentPosition = widgetOffset.dy;

    if (_currentPosition < 0 && _currentPosition >= -100) {
      setState(() {
        opacity = 1 - _currentPosition.abs() / 100;
      });
    } else if (_currentPosition >= 0 && opacity != 1) {
      setState(() {
        opacity = 1;
      });
    } else if (_currentPosition < -100 && opacity != 0) {
      setState(() {
        opacity = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productRepository = context.watch<ProductRepository>();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: PhysicalModel(
          color: HavkaColors.cream,
          elevation: 20,
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: opacity,
                duration: Duration.zero,
                child: Container(
                  alignment: AlignmentDirectional.topCenter,
                  height: double.infinity,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0, 0.25],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      children: iconsList,
                    ),
                  ),
                ),
              ),
              Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: SafeArea(
                    key: backgroundWidgetKey,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 30.0),
                            child: Column(
                              children: [
                                Icon(
                                  widget.product == null
                                      ? CupertinoIcons.add_circled
                                      : CupertinoIcons.pencil_circle,
                                  color: HavkaColors.green,
                                  size: 70,
                                ),
                              ],
                            ),
                          ),
                          RoundedTextField(
                            hintText: "Barcode",
                            controller: barcodeController,
                            keyboardType: TextInputType.number,
                            focusNode: barcodeFocusNode,
                            onSubmitted: (_) =>
                                packSizeValueFocusNode.requestFocus(),
                            iconButton: IconButton(
                              icon: Icon(
                                CupertinoIcons.barcode_viewfinder,
                                size: 24,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              color: HavkaColors.green,
                              onPressed: () async {
                                final String? barcode =
                                    await _buildBarcodeScanner();
                                setState(() {
                                  if (barcode != null) {
                                    barcodeController.text = barcode;
                                  }
                                });
                              },
                            ),
                            descriptionText: Text(
                              "Type a barcode or scan by barcode icon",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        width: 70,
                                        child: ColoredBox(
                                          color: HavkaColors.cream,
                                          child: Center(
                                            child: Text(
                                              "Pack",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              margin: EdgeInsets.only(right: 5.0),
                                              child: RoundedTextField(
                                                hintText: "Name",
                                                controller:
                                                _servingControllers[0]["name"],
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(10),
                                                ],
                                                textCapitalization:
                                                TextCapitalization.none,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5.0),
                                              child: RoundedTextField(
                                                  hintText: "Size",
                                                  enableClearButton: false,
                                                  controller:
                                                  _servingControllers[0]["value"],
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    CommaToDotFormatter(),
                                                    LengthLimitingTextInputFormatter(10),
                                                  ],
                                                  dropDownItemsList:
                                                  packSizeUnits,
                                                  onSelectedDropDownItem: (item) {
                                                    setState(() {
                                                      packSizeUnit = item;
                                                    });
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        width: 160,
                                        child: ColoredBox(
                                          color: HavkaColors.cream,
                                          child: Center(
                                            child: Text(
                                              "Servings (max. 3)",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    for (int i = 1;
                                        i < _servingControllers.length;
                                        i++)
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              margin: EdgeInsets.only(right: 5.0),
                                              child: RoundedTextField(
                                                hintText: "Name",
                                                controller:
                                                _servingControllers[i]["name"],
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(10),
                                                ],
                                                textCapitalization:
                                                    TextCapitalization.none,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5.0),
                                              child: RoundedTextField(
                                                  hintText: "Size",
                                                  enableClearButton: false,
                                                  controller:
                                                  _servingControllers[i]["value"],
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    CommaToDotFormatter(),
                                                    LengthLimitingTextInputFormatter(10),
                                                  ],
                                                  trailingText: packSizeUnit,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _servingControllers.last["name"]!.text.isEmpty || _servingControllers.last["value"]!.text.isEmpty ||  _servingControllers.length > 3
                                ? SizedBox.shrink()
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        _servingControllers.add({
                                          "name": TextEditingController(),
                                          "value": TextEditingController(),
                                        });
                                        _servingControllers.last["name"]?.addListener(() => setState(() {
                                          if(_servingControllers.last["value"]!.text.isNotEmpty && perServing.valueInBaseUnit == double.parse(_servingControllers.last["value"]!.text)) {
                                            perServing = perServingList.first;
                                          }
                                        }));
                                        _servingControllers.last["value"]?.addListener(() => setState(() {
                                          if(_servingControllers.last["name"]!.text.isNotEmpty && perServing.valueInBaseUnit == _servingControllers.last["name"]!.text) {
                                            perServing = perServingList.first;
                                          }
                                        }));
                                      });
                                    },
                                    child: Container(
                                      alignment: AlignmentDirectional.center,
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                      child: Text(
                                        "+ Add serving",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Divider(
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 100,
                                  child: ColoredBox(
                                    color: HavkaColors.cream,
                                    child: Center(
                                      child: Text(
                                        "Basic Info",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RoundedTextField(
                            hintText: "Name",
                            controller: nameController,
                            focusNode: nameFocusNode,
                            onSubmitted: (_) => brandFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Brand",
                            controller: brandController,
                            focusNode: brandFocusNode,
                            onSubmitted: (_) =>
                                energyValueFocusNode.requestFocus(),
                          ),
                          SizedBox(
                            height: 40,
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Divider(
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 230,
                                  child: ColoredBox(
                                    color: HavkaColors.cream,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Nutrition facts",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            perServingList = perServingList.sublist(0, 1);
                                            if (_servingControllers.where((e) => e["name"]!.text.isNotEmpty && e["value"]!.text.isNotEmpty).length > 0) {
                                              perServingList.addAll(_servingControllers.where((e) => e["name"]!.text.isNotEmpty && e["value"]!.text.isNotEmpty).map((e) => Serving(name: e["name"]!.text, valueInBaseUnit: double.parse(e["value"]!.text))));
                                            }
                                            perServingList.sort((a, b) {
                                              if(a.valueInBaseUnit == 100) {
                                                return -1;
                                              }
                                              return a.valueInBaseUnit.compareTo(
                                                  b.valueInBaseUnit);
                                            });
                                            final perServingStr = "per ${perServing.valueInBaseUnit == 100 ? Utils().formatNumber(perServing.valueInBaseUnit) : 1} ${perServing.valueInBaseUnit == 100 ? packSizeUnit : perServing.name}";
                                            final TextPainter perServingTextPainter = TextPainter(
                                              text: TextSpan(
                                                text: perServingStr,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              textDirection: TextDirection.ltr,
                                            );
                                            perServingTextPainter.layout();
                                            if (_servingControllers.where((element) => element["name"]!.text.isNotEmpty && element["value"]!.text.isNotEmpty).length == 0) {
                                              return Container(
                                                height: 30,
                                                width: perServingTextPainter.width + 20.0,
                                                alignment: AlignmentDirectional.center,
                                                child: Text(
                                                  perServingStr,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }
                                            return Container(
                                              height: 30,
                                              width: perServingTextPainter.width + 20.0,
                                              child: DropdownButton(
                                                isExpanded: true,
                                                alignment: AlignmentDirectional.center,
                                                underline: Container(),
                                                borderRadius: BorderRadius.circular(10.0),
                                                icon: Visibility(
                                                    visible: false,
                                                    child: Icon(Icons.arrow_downward)),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                value: perServing,
                                                items: perServingList.map((e) => DropdownMenuItem<Serving>(
                                                    value: e,
                                                    child: Container(
                                                      child: Text('per ${e.valueInBaseUnit == 100 ? Utils().formatNumber(e.valueInBaseUnit) : 1} ${e.valueInBaseUnit == 100 ? packSizeUnit : e.name}'),
                                                    )
                                                )).toList(),
                                                selectedItemBuilder: (context) {
                                                  return perServingList.map((e) => Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.05),
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    alignment: AlignmentDirectional.center,
                                                    child: Text(perServingStr),
                                                  )).toList();
                                                },
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    perServing = newValue!;
                                                  });
                                                },
                                              ),
                                            );
                                          }
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RoundedTextField(
                            hintText: "Energy",
                            fillColor: HavkaColors.energy.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.energy,
                              color: HavkaColors.energy,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: energyValueController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            focusNode: energyValueFocusNode,
                            onSubmitted: (_) => fatFocusNode.requestFocus(),
                            dropDownItemsList: energyUnits,
                            onSelectedDropDownItem: (item) => energyUnit = item,
                          ),
                          RoundedTextField(
                            hintText: "Fat",
                            fillColor: HavkaColors.fat.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.fat,
                              color: HavkaColors.fat,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: fatController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: fatFocusNode,
                            onSubmitted: (_) => saturatedFatFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Saturated fat",
                            fillColor: HavkaColors.fat.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.fat,
                              color: HavkaColors.fat,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: saturatedFatController,
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: saturatedFatFocusNode,
                            onSubmitted: (_) => monounsaturatedFatFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Monounsaturated fat",
                            fillColor: HavkaColors.fat.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.fat,
                              color: HavkaColors.fat,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: monounsaturatedFatController,
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: monounsaturatedFatFocusNode,
                            onSubmitted: (_) => polyunsaturatedFatFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Polyunsaturated fat",
                            fillColor: HavkaColors.fat.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.fat,
                              color: HavkaColors.fat,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: polyunsaturatedFatController,
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: polyunsaturatedFatFocusNode,
                            onSubmitted: (_) => transFatFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Trans fat",
                            fillColor: HavkaColors.fat.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.fat,
                              color: HavkaColors.fat,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: transFatController,
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: transFatFocusNode,
                            onSubmitted: (_) => carbsFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Carbs",
                            fillColor: HavkaColors.carbs.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.carbs,
                              color: HavkaColors.carbs,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: carbsController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: carbsFocusNode,
                            onSubmitted: (_) => sugarsFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Sugars",
                            fillColor: HavkaColors.carbs.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.sugars,
                              color: HavkaColors.carbs,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: sugarsController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: sugarsFocusNode,
                            onSubmitted: (_) => fiberFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Fiber",
                            fillColor: HavkaColors.carbs.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.sugars,
                              color: HavkaColors.carbs,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: fiberController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: fiberFocusNode,
                            onSubmitted: (_) => proteinFocusNode.requestFocus(),
                          ),
                          RoundedTextField(
                            hintText: "Protein",
                            fillColor: HavkaColors.protein.withValues(alpha: 0.2),
                            prefixIcon: Icon(
                              HavkaIcons.protein,
                              color: HavkaColors.protein,
                              size: 18,
                            ),
                            enableClearButton: false,
                            controller: proteinController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              CommaToDotFormatter(),
                            ],
                            trailingText: Units.g,
                            focusNode: proteinFocusNode,
                            onSubmitted: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                          SubmitButton(
                            text: 'Done',
                            onSubmit: () async {
                              await _adjustProduct(productRepository);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _energyUnitCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        energyUnit = selectedValue;
      });
    }
  }

  void _packSizeUnitCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        packSizeUnit = selectedValue;
      });
    }
  }

  Future<String?> _buildBarcodeScanner() async {
    List<CameraDescription> cameras = await availableCameras();
    final firstCamera = cameras.first;
    String? barcode = await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      context: context,
      builder: (builder) {
        final double mHeight = MediaQuery.of(context).size.height;
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: SizedBox(
            height: mHeight * 0.75,
            child: HavkaBarcodeScannerScreen(
              camera: firstCamera,
              isProduct: false,
            ),
          ),
        );
      },
    );
    return barcode;
  }

  Future _adjustProduct(ProductRepository productRepository) async {
    final List<Serving> _servings = <Serving>[];
    _servings.add(
      Serving(name: packSizeUnit, valueInBaseUnit: 1)
    );
    if (_servingControllers.where((element) => element["name"]!.text.isNotEmpty && element["value"]!.text.isNotEmpty).length > 0) {
      _servings.addAll(
          _servingControllers.where((element) => element["name"]!.text.isNotEmpty && element["value"]!.text.isNotEmpty).map((element) {
            return Serving(
              name: element["name"]!.text,
              valueInBaseUnit: double.parse(element["value"]!.text),
            );
          }).toList());
    }
    final Map<String, TextEditingController> packServing = _servingControllers[0];
    final Product product = Product(
      id: widget.product?.id,
      name: nameController.text,
      brand: Brand(
        name: brandController.text,
        type: "popular",
      ),
      nutrition: Nutrition(
        valuePerInBaseUnit: perServing.valueInBaseUnit,
        unit: "g",
        protein: Protein(
          total: proteinController.text.isNotEmpty ? double.parse(proteinController.text) : 0.0,
        ),
        fat: Fat(
          total: fatController.text.isNotEmpty ? double.parse(fatController.text) : 0.0,
          saturated: saturatedFatController.text.isNotEmpty ? double.parse(saturatedFatController.text) : 0.0,
          monounsaturated: monounsaturatedFatController.text.isNotEmpty ? double.parse(monounsaturatedFatController.text) : 0.0,
          polyunsaturated: polyunsaturatedFatController.text.isNotEmpty ? double.parse(polyunsaturatedFatController.text) : 0.0,
          trans: transFatController.text.isNotEmpty ? double.parse(transFatController.text) : 0.0,
        ),
        carbs: Carbs(
          total: carbsController.text.isNotEmpty ? double.parse(carbsController.text) : 0.0,
          sugars: sugarsController.text.isNotEmpty ? double.parse(sugarsController.text) : 0.0,
          dietaryFiber: fiberController.text.isNotEmpty ? double.parse(fiberController.text) : 0.0,
        ),
        energy: energyValueController.text.isNotEmpty
            ? Energy(
                kcal: double.parse((double.parse(energyValueController.text) *
                        (energyUnit == "kcal" ? 1.0 : 0.239006))
                    .toStringAsFixed(1)),
                kJ: double.parse((double.parse(energyValueController.text) *
                        (energyUnit == "kJ" ? 1.0 : 4.184))
                    .toStringAsFixed(1)),
              )
            : null,
      ),
      serving: _servings,
      package: Package(
        unit: packSizeUnit,
        value: double.parse(packServing["value"]!.text),
      ),
      baseUnit: packSizeUnit,
      barcode: barcodeController.text,
    );
    if (widget.product != null) {
      await productRepository.updateProduct(product);
    } else {
      await productRepository.addProduct(product);
    }
    Navigator.pop(context, product);
  }
}
