import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/constants/utils.dart';
import 'package:havka/model/user_consumption_item.dart';
import 'package:havka/model/user_device.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:havka/ui/screens/product_adjustment_screen.dart';
import 'package:havka/ui/screens/stats_screen.dart';
import 'package:havka/ui/widgets/progress_bar_popup.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:havka/ui/widgets/rounded_button.dart';
import 'package:havka/ui/widgets/rounded_textfield.dart';
import 'package:havka/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../constants/icons.dart';
import '../../model/product.dart';

OverlayEntry? _overlayEntry;

class ScaleScreen extends StatefulWidget {
  final UserFridgeItem? userProduct;
  final UserDevice? userDevice;

  const ScaleScreen({
    this.userProduct,
    this.userDevice,
  });

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen>
    with SingleTickerProviderStateMixin {
  final ApiRoutes _apiRoutes = ApiRoutes();

  final ScrollController _scrollController = ScrollController();

  late ButtonStyle buttonStyle;
  late Widget addButtonContent;

  int _currentIndex = 0;
  late List<Serving> servingNutrition;

  late Offset _topOffset;
  late double _topBlurRadius;
  late Offset _bottomOffset;
  late double _bottomBlurRadius;

  late double weightInServing;
  double? weight;
  double? protein;
  double? fats;
  double? carbs;
  double? kcal;
  late DateTime selectedDateTime;
  late ValueNotifier<double> progressBarValueNotifier;
  final GlobalKey<SliverAnimatedListState> _userConsumptionListKeyIOS =
      GlobalKey<SliverAnimatedListState>();
  final GlobalKey<AnimatedListState> _userConsumptionListKeyAndroid =
      GlobalKey<AnimatedListState>();
  late ValueNotifier<List<UserConsumptionItem>?> productConsumption;

  String prevText = '';
  final FocusNode _weightFocusNode = FocusNode();
  final TextEditingController weightController = TextEditingController();
  String? weightError;
  late List<Serving>? servingUnits;
  late List<String> servingUnitNames;
  late String selectedServingUnit;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _topOffset = Offset.zero;
    _topBlurRadius = 0;
    _bottomOffset = Offset.zero;
    _bottomBlurRadius = 0;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent) {
        setState(() {
          _topOffset = Offset.zero;
          _topBlurRadius = 0.0;
        });
      } else if (_scrollController.position.pixels > 5.0) {
        setState(() {
          _topOffset = Offset(0.0, 2.0);
          _topBlurRadius = 1.0;
        });
      } else {
        setState(() {
          _topOffset = Offset(0.0, _scrollController.position.pixels / 2.5);
          _topBlurRadius = _scrollController.position.pixels / 5.0;
        });
      }

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        setState(() {
          _bottomOffset = Offset.zero;
          _bottomBlurRadius = 0.0;
        });
      } else if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent * 0.95) {
        setState(() {
          _bottomOffset = Offset(0.0, -2.0);
          _bottomBlurRadius = 1.0;
        });
      } else {
        setState(() {
          _bottomOffset = Offset(0.0, -2.0 + _scrollController.position.pixels / _scrollController.position.maxScrollExtent);
          _bottomBlurRadius = 1.0 - _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
        });
      }

    });

    buttonStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.transparent),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black.withOpacity(0.05), // your color here
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30))),
    );

    addButtonContent = Text(
      "Add",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    );

    weightInServing = 0.0;
    weight = 0.0;
    protein = 0.0;
    fats = 0.0;
    carbs = 0.0;
    kcal = 0.0;
    selectedDateTime = DateTime.now();
    progressBarValueNotifier = ValueNotifier<double>(0);
    productConsumption = ValueNotifier<List<UserConsumptionItem>?>(null);
    () async {
      productConsumption.value = await _apiRoutes
          .getUserConsumptionByProduct(widget.userProduct!.product!);
    }();

    servingNutrition = [
      Serving(
        name: widget.userProduct!.product!.baseUnit!,
        valueInBaseUnit: 100,
      )
    ];
    servingNutrition.addAll(widget.userProduct!.product!.serving.whereNot((el) => el.valueInBaseUnit == 1).sorted((a, b) => a.valueInBaseUnit.compareTo(b.valueInBaseUnit)));

    servingUnits = widget.userProduct?.product!.serving.sorted((a, b) => a.valueInBaseUnit.compareTo(b.valueInBaseUnit));
    servingUnitNames = servingUnits!.map((e) => e.name).toList();
    selectedServingUnit = servingUnits!.firstWhere((element) => element.valueInBaseUnit > 1).name;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    weightController.addListener(_changeNutritionValues);
    weightController.addListener(_onFocusWeight);
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  void showProgressBarPopup() {
    _overlayEntry = OverlayEntry(
      builder: (context) => ValueListenableBuilder(
        valueListenable: progressBarValueNotifier,
        builder: (context, double progressBarValue, child) => ProgressBarPopup(
          animationController: _animationController,
          value: progressBarValue,
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      progressBarValueNotifier.value += kcal!;
    });
    // Timer.periodic(const Duration(seconds: 3), (timer) {
    //   progressBarValueNotifier.value += 500;
    // });
    Future.delayed(const Duration(seconds: 3), hideProgressBarPopup);
  }

  void hideProgressBarPopup() {
    _animationController.reverse().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _onFocusWeight() {
    if (_weightFocusNode.hasFocus) {
      setState(() => weightError = null);
    }
  }

  void _changeNutritionValues() {
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
      weightInServing = newText.isEmpty ? 0.0 : double.parse(newText);
      weight = weightInServing * widget.userProduct!.product!.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit;
      if (weight! < 0.0001) {
        buttonStyle = ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.transparent),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.black.withOpacity(0.05), // your color here
                width: 2,
              ),
              borderRadius: BorderRadius.circular(30))),
        );
      } else {
        buttonStyle = ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.05)),
        );
      }
      weightController.text = weight! > widget.userProduct!.amount!.value! ? Utils().formatNumber(widget.userProduct!.amount!.value! / widget.userProduct!.product!.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit)! : newText;
    }
    setState(() {});
  }

  Widget consumptionItem(context, list, index, animation) {
    final UserConsumptionItem
    userConsumptionItem =
    list[index];
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: GestureDetector(
          onDoubleTap: () {
            _removeItem(
                userConsumptionItem,
                index,
                context);
          },
          child: Padding(
            padding: EdgeInsets
                .symmetric(
                vertical:
                15.0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Text(
                        '${formattedNumber(userConsumptionItem.consumedAmount!.value)} ${userConsumptionItem.consumedAmount!.serving.name}',
                        style: Theme.of(
                            context)
                            .textTheme
                            .displayLarge,
                      ),
                      Text(
                          '= ${formattedNumber(userConsumptionItem.consumedAmount!.value * userConsumptionItem.consumedAmount!.serving.valueInBaseUnit)} ${userConsumptionItem.product!.baseUnit}',
                          style: TextStyle(
                            color: Colors.grey,
                          )
                      ),
                    ],
                  ),
                ),
                Text(
                  formatDate(
                    userConsumptionItem.consumedAt
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    protein = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.protein!.total!
          / widget.userProduct!.product!.nutrition!.valuePerInBaseUnit!
          * weight!
        : 0;
    fats = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.fat!.total!
          / widget.userProduct!.product!.nutrition!.valuePerInBaseUnit!
          * weight!
        : 0;
    carbs = widget.userProduct!.product!.nutrition != null
        ? widget.userProduct!.product!.nutrition!.carbs!.total!
          / widget.userProduct!.product!.nutrition!.valuePerInBaseUnit!
          * weight!
        : 0;
    kcal = widget.userProduct!.product!.nutrition != null &&
            widget.userProduct!.product!.nutrition!.energy!.kcal != null
        ? widget.userProduct!.product!.nutrition!.energy!.kcal!
          / widget.userProduct!.product!.nutrition!.valuePerInBaseUnit!
          * weight!
        : 0;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: PhysicalModel(
          color: HavkaColors.cream,
          elevation: 20,
          child: SafeArea(
            child: Container(
              child:
                  Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 235,
                    margin: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      // vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      // color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            left: 30.0,
                            right: 30.0,
                            top: 20.0,
                          ),
                          child: InkWell(
                            onDoubleTap: () async {
                              final Product? p = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductAdjustmentScreen(
                                        product: widget.userProduct!.product!,
                                      ),
                                ),
                              );
                              if (p != null) {
                                setState(() {
                                  widget.userProduct!.product!.set(p);
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 20.0),
                                  child: widget.userProduct!.product!
                                      .images !=
                                      null
                                      ? Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.05),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          widget.userProduct!.product!
                                              .images!.original!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                    ),
                                  )
                                      : Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withOpacity(0.05),
                                        borderRadius:
                                        BorderRadius.circular(
                                            30.0),
                                      ),
                                      child: const Icon(
                                        HavkaIcons.bowl,
                                        color: HavkaColors.energy,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      showLabel(
                                          widget.userProduct!.product!.name!,
                                          maxSymbols: 20),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      showLabel(
                                          widget.userProduct!.product!.brand!.name,
                                          maxSymbols: 30),
                                      style: TextStyle(
                                        fontSize: 12,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _currentIndex = (_currentIndex + 1) % servingNutrition.length;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 20.0,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "per",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        servingNutrition[_currentIndex].valueInBaseUnit == 100
                                          ? "${Utils().formatNumber(servingNutrition[_currentIndex].valueInBaseUnit)} ${widget.userProduct!.product!.baseUnit}"
                                          : "1 ${servingNutrition[_currentIndex].name} (${Utils().formatNumber(servingNutrition[_currentIndex].valueInBaseUnit)} ${widget.userProduct!.product!.baseUnit})",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 5,
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 6.0),
                                            child: Icon(
                                              FontAwesomeIcons.dna,
                                              size: 12,
                                              color: HavkaColors.protein,
                                            ),
                                          ),
                                          const Text(
                                            "Protein",
                                            style: TextStyle(
                                              color: HavkaColors.protein,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            Utils().formatNumber(widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .protein!
                                                    .total!
                                                    /
                                                    widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .valuePerInBaseUnit!
                                                    *
                                                servingNutrition[_currentIndex]
                                                        .valueInBaseUnit)
                                            ?? "-",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: HavkaColors.protein,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Container(
                                            margin:
                                                EdgeInsets.only(left: 2.0),
                                            child: Text(
                                              "g",
                                              style: const TextStyle(
                                                color: HavkaColors.protein,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 6.0),
                                            child: Icon(
                                              FontAwesomeIcons.droplet,
                                              size: 12,
                                              color: HavkaColors.fat,
                                            ),
                                          ),
                                          const Text(
                                            "Fat",
                                            style: TextStyle(
                                              color: HavkaColors.fat,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            Utils().formatNumber(widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .fat!
                                                    .total!
                                                /
                                                widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .valuePerInBaseUnit!
                                                *
                                                servingNutrition[_currentIndex]
                                                    .valueInBaseUnit
                                            ) ?? "-",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: HavkaColors.fat,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Container(
                                            margin:
                                                EdgeInsets.only(left: 2.0),
                                            child: Text(
                                              "g",
                                              style: const TextStyle(
                                                color: HavkaColors.fat,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 6.0),
                                            child: Icon(
                                              HavkaIcons.carbs,
                                              size: 12,
                                              color: HavkaColors.carbs,
                                            ),
                                          ),
                                          const Text(
                                            "Carbs",
                                            style: TextStyle(
                                              color: HavkaColors.carbs,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            Utils().formatNumber(widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .carbs!
                                                    .total!
                                                /
                                                widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .valuePerInBaseUnit!
                                                *
                                                servingNutrition[_currentIndex]
                                                    .valueInBaseUnit
                                            ) ?? "-",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: HavkaColors.carbs,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Container(
                                            margin:
                                                EdgeInsets.only(left: 2.0),
                                            child: Text(
                                              "g",
                                              style: TextStyle(
                                                color: HavkaColors.carbs,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 6.0),
                                            child: Icon(
                                              HavkaIcons.energy,
                                              size: 12,
                                              color: HavkaColors.energy,
                                            ),
                                          ),
                                          Text(
                                            "Energy",
                                            style: TextStyle(
                                              color: HavkaColors.energy,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            Utils().formatNumber(widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .energy!
                                                    .kcal!
                                                /
                                                widget
                                                    .userProduct!
                                                    .product!
                                                    .nutrition!
                                                    .valuePerInBaseUnit!
                                                *
                                                servingNutrition[_currentIndex]
                                                    .valueInBaseUnit
                                            ) ?? "-",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: HavkaColors.energy,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Container(
                                            margin:
                                                EdgeInsets.only(left: 2.0),
                                            child: Text(
                                              "kcal",
                                              style: TextStyle(
                                                color: HavkaColors.energy,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        MediaQuery.of(context).viewInsets.bottom -
                        355,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (_scrollController.position.pixels != _scrollController.position.minScrollExtent) {
                              _scrollController.animateTo(
                                _scrollController.position.minScrollExtent,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: HavkaColors.bone[100],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: _topOffset,
                                  blurRadius: _topBlurRadius,
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(top: 8.0),
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                "Consumption History",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ValueListenableBuilder(
                              valueListenable: productConsumption,
                              builder: ((context, value, _) {
                                if (value == null) {
                                  return SizedBox(
                                    // height: 250,
                                    child: const Center(
                                      child: HavkaProgressIndicator(),
                                    ),
                                  );
                                }
                                if (value.isEmpty) {
                                  return SizedBox(
                                    // height: 250,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.scale_rounded,
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            size: 50,
                                          ),
                                        ),
                                        Text("No history found",
                                            style: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.4),
                                            )),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Scrollbar(
                                    controller: _scrollController,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Builder(builder: (context) {
                                        final List<UserConsumptionItem>
                                        _userConsumption = value;
                                        _userConsumption.sort(
                                              (prev, next) =>
                                              next.consumedAt
                                                  .compareTo(
                                                prev.consumedAt
                                              ),
                                        );
                                        if (Platform.isAndroid) {
                                          return AnimatedList(
                                            key:
                                                _userConsumptionListKeyAndroid,
                                            controller: _scrollController,
                                            initialItemCount: value.length,
                                            itemBuilder:
                                                (BuildContext context,
                                                    int index, animation) => consumptionItem(context, value, index, animation)
                                          );
                                        } else {
                                          return CustomScrollView(
                                            controller: _scrollController,
                                            slivers: [
                                              SliverAnimatedList(
                                                key:
                                                    _userConsumptionListKeyIOS,
                                                initialItemCount:
                                                    value.length,
                                                itemBuilder: (context, index,
                                                    animation) => consumptionItem(context, value, index, animation),
                                              ),
                                            ],
                                          );
                                        }
                                      }),
                                    ),
                                  );
                                }
                              })),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 120,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: HavkaColors.cream,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: _bottomOffset,
                                blurRadius: _bottomBlurRadius,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 5.0,
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.dna,
                                      size: 12,
                                      color: HavkaColors.protein,
                                    ),
                                  ),
                                  Text(
                                    Utils().formatNumber(protein!) ?? "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HavkaColors.protein,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      "g",
                                      style: TextStyle(
                                        color: HavkaColors.protein,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 5.0,
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.droplet,
                                      size: 12,
                                      color: HavkaColors.fat,
                                    ),
                                  ),
                                  Text(
                                    Utils().formatNumber(fats!) ?? "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HavkaColors.fat,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      "g",
                                      style: TextStyle(
                                        color: HavkaColors.fat,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 5.0,
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.wheatAwn,
                                      size: 12,
                                      color: HavkaColors.carbs,
                                    ),
                                  ),
                                  Text(
                                    Utils().formatNumber(carbs!) ?? "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HavkaColors.carbs,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      "g",
                                      style: TextStyle(
                                        color: HavkaColors.carbs,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 20.0,
                                      right: 5.0,
                                    ),
                                    child: Icon(
                                      HavkaIcons.energy,
                                      size: 12,
                                      color: HavkaColors.energy,
                                    ),
                                  ),
                                  Text(
                                    Utils().formatNumber(kcal!) ?? "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HavkaColors.energy,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      "kcal",
                                      style: TextStyle(
                                        color: HavkaColors.energy,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: [
                                    RoundedTextField(
                                      hintText: "Type...",
                                      focusNode: _weightFocusNode,
                                      controller: weightController,
                                      enableClearButton: false,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^(\d+)?[\.\,]?\d{0,2}'),
                                        ),
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      dropDownItemsList: servingUnitNames,
                                      dropDownInitialValue: servingUnits!.firstWhere((element) => element.valueInBaseUnit > 1).name,
                                      onSelectedDropDownItem: (value) => setState(() {
                                        selectedServingUnit = value;
                                        weightInServing = weightController.text.isEmpty ? 0 : double.parse(weightController.text);
                                        weight = weightInServing * widget.userProduct!.product!.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit;
                                      }),
                                      trailingText: weightController.text != '' && widget.userProduct!.product!.serving.firstWhere((element) => element.name == selectedServingUnit).name != widget.userProduct!.product!.baseUnit
                                          ? "= ${formattedNumber(double.parse(weightController.text) * widget.userProduct!.product!.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit)} ${widget.userProduct!.product!.baseUnit}"
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
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
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            child: CupertinoDatePicker(
                                              use24hFormat: true,
                                              initialDateTime: DateTime.now(),
                                              minimumDate: DateTime.now()
                                                  .subtract(
                                                      Duration(days: 365)),
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
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Padding(
                                        //   padding: EdgeInsets.only(right: 8.0),
                                        //   child: Icon(
                                        //     CupertinoIcons.calendar,
                                        //     // FontAwesomeIcons.calendar,
                                        //     size: 22,
                                        //   ),
                                        // ),
                                        Text(
                                          formatDate(selectedDateTime),
                                        ),
                                      ]),
                                ),
                              ),
                              TextButton(
                                child: addButtonContent,
                                style: buttonStyle,
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus
                                      ?.unfocus();
                                  if (weightController.text.isEmpty ||
                                      weight! < 0.0001) {
                                    return;
                                  }
                                  addButtonContent = HavkaProgressIndicator();
                                  final Serving selectedServing = widget.userProduct!.product!.serving.firstWhere((element) => element.name == selectedServingUnit);
                                  final UserConsumptionItem
                                      userConsumptionItem =
                                      UserConsumptionItem(
                                    productId:
                                        widget.userProduct!.productId,
                                    product: widget.userProduct!.product!,
                                    fridgeItemId: widget.userProduct!.id,
                                    consumedAmount: ConsumedAmount(
                                        serving: Serving(
                                            name: selectedServing.name,
                                            valueInBaseUnit: selectedServing.valueInBaseUnit),
                                        value: weightInServing),
                                    consumedAt: selectedDateTime,
                                  );
                                  await _insertItem(userConsumptionItem);
                                  addButtonContent = Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  );
                                  weightController.clear();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // })
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _insertItem(UserConsumptionItem userConsumptionItem) async {
    final UserConsumptionItem? newUCI = await _apiRoutes.addUserConsumptionItem(
        userConsumptionItem: userConsumptionItem);
    context.read<DailyProgressDataModel>().initData();
    context.read<WeeklyProgressDataModel>().initData();
    if (Platform.isIOS) {
      _userConsumptionListKeyIOS.currentState?.insertItem(0);
    } else if (Platform.isAndroid) {
      _userConsumptionListKeyAndroid.currentState?.insertItem(0);
    }
    if (newUCI != null) {
      setState(() {
        productConsumption.value?.insert(0, newUCI);
      });
    }
  }

  void _removeItem(UserConsumptionItem userConsumptionItem, int index,
      BuildContext context) async {
    if (Platform.isIOS) {
      await _apiRoutes.deleteUserConsumption(userConsumptionItem);
      context.read<DailyProgressDataModel>().initData();
      context.read<WeeklyProgressDataModel>().initData();
      SliverAnimatedList.of(context).removeItem(index, (context, animation) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(animation),
          child: SizeTransition(
            sizeFactor: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.5),
                end: Offset.zero,
              ).animate(animation),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formattedNumber(userConsumptionItem.consumedAmount!.value)} ${userConsumptionItem.consumedAmount!.serving.name}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      formatDate(
                        userConsumptionItem.consumedAt
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
      setState(() {
        productConsumption.value?.removeAt(index);
      });
    } else if (Platform.isAndroid) {
      await _apiRoutes.deleteUserConsumption(userConsumptionItem);
      AnimatedList.of(context).removeItem(
        index,
        (_, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${formattedNumber(userConsumptionItem.consumedAmount!.value)} ${userConsumptionItem.consumedAmount!.serving.name}',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      Text(
                        formatDate(
                          userConsumptionItem.consumedAt,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        duration: const Duration(milliseconds: 200),
      );
      setState(() {
        productConsumption.value?.removeAt(index);
      });
    }
  }
}
