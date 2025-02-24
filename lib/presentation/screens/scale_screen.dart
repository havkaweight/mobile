import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:havka/presentation/widgets/submit_button.dart';
import '../../data/models/consumption/user_consumption_item_model.dart';
import '../../domain/entities/consumption/consumed_amount.dart';
import '../../domain/entities/device/user_device.dart';
import '../../domain/entities/product/fridge_item.dart';
import '../../domain/entities/product/serving.dart';
import '../../utils/format_date.dart';
import '../../utils/format_number.dart';
import '../providers/consumption_provider.dart';
import '../widgets/nutrition_info.dart';
import '/core/constants/colors.dart';
import '/core/constants/utils.dart';
import '../../domain/entities/consumption/user_consumption_item.dart';
import '/presentation/screens/product_adjustment_screen.dart';
import '/presentation/widgets/progress_indicator.dart';
import '/presentation/widgets/rounded_textfield.dart';
import 'package:provider/provider.dart';
import '/core/constants/icons.dart';
import '../../domain/entities/product/product.dart';


class ScaleScreen extends StatefulWidget {
  final FridgeItem? fridgeItem;
  final UserDevice? userDevice;

  const ScaleScreen({
    this.fridgeItem,
    this.userDevice,
  });

  @override
  _ScaleScreenState createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen>
    with SingleTickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;
  late List<Serving> servingNutrition;

  late Offset _topOffset;
  late double _topBlurRadius;
  late Offset _bottomOffset;
  late double _bottomBlurRadius;

  late double weightInServing;
  double? weight;
  late DateTime selectedDateTime;
  late ValueNotifier<double> progressBarValueNotifier;
  final GlobalKey<SliverAnimatedListState> _userConsumptionListKeyIOS =
      GlobalKey<SliverAnimatedListState>();
  final GlobalKey<AnimatedListState> _userConsumptionListKeyAndroid =
      GlobalKey<AnimatedListState>();

  String prevText = '';
  final FocusNode _weightFocusNode = FocusNode();
  final TextEditingController weightController = TextEditingController();
  String? weightError;
  late List<Serving>? servingUnits;
  late List<String> servingUnitNames;
  late String selectedServingUnit;
  late AnimationController _animationController;

  bool _showTopShadow = false;
  bool _showBottomShadow = false;
  final GlobalKey _listKey = GlobalKey();
  final GlobalKey _listAreaKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final ConsumptionProvider consumptionProvider = context.read<ConsumptionProvider>();
      await consumptionProvider.fetchConsumptionByProduct(widget.fridgeItem!.product);
    });

    _topOffset = Offset.zero;
    _topBlurRadius = 0;
    _bottomOffset = Offset.zero;
    _bottomBlurRadius = 0;

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    _scrollController.addListener(_onScroll);

    weightInServing = 0.0;
    weight = 0.0;
    selectedDateTime = DateTime.now();
    progressBarValueNotifier = ValueNotifier<double>(0);

    servingNutrition = [
      Serving(
        name: widget.fridgeItem!.product.baseUnit!,
        valueInBaseUnit: 100,
      )
    ];
    servingNutrition.addAll(widget.fridgeItem!.product.serving.whereNot((el) => el.valueInBaseUnit == 1).sorted((a, b) => a.valueInBaseUnit.compareTo(b.valueInBaseUnit)));

    servingUnits = widget.fridgeItem?.product.serving.sorted((a, b) => a.valueInBaseUnit.compareTo(b.valueInBaseUnit));
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _afterLayout(Duration timeStamp) {
    final listContext = _listKey.currentContext;
    final listAreaContext = _listAreaKey.currentContext;
    if (listContext != null && listAreaContext != null) {
      final listSize = listContext.size;
      final listAreaSize = listAreaContext.size;
      if (listSize != null && listAreaSize != null) {
        setState(() {
          _showBottomShadow = listSize.height > listAreaSize.height;
        });
      }
    }
  }

  void _onScroll() {
    setState(() {
      _showTopShadow = _scrollController.offset > 0;
      _showBottomShadow =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void hideProgressBarPopup() {
    _animationController.reverse();
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
      weight = weightInServing * widget.fridgeItem!.product.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit;
      weightController.text = weight! > widget.fridgeItem!.amount.value ? Utils().formatNumber(widget.fridgeItem!.amount.value / widget.fridgeItem!.product.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit)! : newText;
    }
    setState(() {});
  }

  Widget ConsumptionItemRow(UserConsumptionItem userConsumptionItem) {
    return Padding(
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
                  '${formatNumber(userConsumptionItem.consumedAmount!.value)} ${userConsumptionItem.consumedAmount!.serving.name}',
                  style: Theme.of(
                      context)
                      .textTheme
                      .displayLarge,
                ),
                Text(
                    '= ${formatNumber(userConsumptionItem.consumedAmount!.value * userConsumptionItem.consumedAmount!.serving.valueInBaseUnit)} ${userConsumptionItem.product!.baseUnit}',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final ConsumptionProvider consumptionProvider = Provider.of<ConsumptionProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                      // color: Colors.black.withValues(alpha: 0.05),
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
                                        product: widget.fridgeItem!.product,
                                      ),
                                ),
                              );
                              if (p != null) {
                                setState(() {
                                  // widget.userProduct!.product.set(p);
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 20.0),
                                  child: widget.fridgeItem!.product
                                      .images !=
                                      null
                                      ? Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          widget.fridgeItem!.product
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
                                            .withValues(alpha: 0.05),
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
                                      widget.fridgeItem!.product.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.fridgeItem!.product.brand!.name,
                                      overflow: TextOverflow.ellipsis,
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
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
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
                                          ? '${Utils().formatNumber(servingNutrition[_currentIndex].valueInBaseUnit)} ${widget.fridgeItem!.product.baseUnit}'
                                          : '1 ${servingNutrition[_currentIndex].name} (${Utils().formatNumber(servingNutrition[_currentIndex].valueInBaseUnit)} ${widget.fridgeItem!.product.baseUnit})',
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
                                    color: Colors.black.withValues(alpha: 0.1),
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
                                              HavkaIcons.protein,
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
                                                    .fridgeItem!
                                                    .product
                                                    .nutrition!
                                                    .protein!
                                                    .total!
                                                    /
                                                    widget
                                                    .fridgeItem!
                                                    .product
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
                                              HavkaIcons.fat,
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
                                                    .fridgeItem!
                                                    .product
                                                    .nutrition!
                                                    .fat!
                                                    .total!
                                                /
                                                widget
                                                    .fridgeItem!
                                                    .product
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
                                                    .fridgeItem!
                                                    .product
                                                    .nutrition!
                                                    .carbs!
                                                    .total!
                                                /
                                                widget
                                                    .fridgeItem!
                                                    .product
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
                                                    .fridgeItem!
                                                    .product
                                                    .nutrition!
                                                    .energy!
                                                    .kcal!
                                                /
                                                widget
                                                    .fridgeItem!
                                                    .product
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
                                  ),
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
                                  color: Colors.black.withValues(alpha: 0.05),
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
                          child: Stack(
                            children: [
                              Consumer<ConsumptionProvider>(
                                  builder: ((context, consumptionProvider, _) {
                                    if (consumptionProvider.isLoading) {
                                      return SizedBox(
                                        // height: 250,
                                        child: const Center(
                                          child: HavkaProgressIndicator(),
                                        ),
                                      );
                                    }
                                    if (consumptionProvider.productConsumption.isEmpty) {
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
                                                    Colors.black.withValues(alpha: 0.4),
                                                size: 50,
                                              ),
                                            ),
                                            Text("No history found",
                                                style: TextStyle(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.4),
                                                )),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Scrollbar(
                                        controller: _scrollController,
                                        child: Container(
                                          key: _listAreaKey,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Builder(builder: (context) {
                                            final List<UserConsumptionItem>
                                            _userConsumption = consumptionProvider.productConsumption;
                                            _userConsumption.sort(
                                                  (prev, next) =>
                                                  next.consumedAt
                                                      .compareTo(
                                                    prev.consumedAt
                                                  ),
                                            );
                                            if (Platform.isAndroid) {
                                              return AnimatedList(
                                                key: _listKey,
                                                controller: _scrollController,
                                                initialItemCount: consumptionProvider.productConsumption.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index, animation) {
                                                  final UserConsumptionItem uci = consumptionProvider.productConsumption[index];
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin: Offset(0, -1),
                                                          end: Offset.zero,
                                                        ).animate(animation),
                                                        child: GestureDetector(
                                                          onDoubleTap: () => _removeItem(
                                                              consumptionProvider,
                                                              uci,
                                                              index),
                                                            child: ConsumptionItemRow(uci))
                                                    )
                                                  );
                                                    }
                                              );
                                            } else {
                                              return CustomScrollView(
                                                controller: _scrollController,
                                                slivers: [
                                                  SliverAnimatedList(
                                                    key: _listKey,
                                                    initialItemCount:
                                                    consumptionProvider.productConsumption.length,
                                                    itemBuilder: (context, index,
                                                        animation) {
                                                      final UserConsumptionItem uci = consumptionProvider.productConsumption[index];
                                                      return FadeTransition(
                                                          opacity: animation,
                                                          child: SlideTransition(
                                                              position: Tween<Offset>(
                                                                begin: Offset(0, -1),
                                                                end: Offset.zero,
                                                              ).animate(animation),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  print(UserConsumptionItemModel.fromDomain(uci));
                                                                },
                                                                  onDoubleTap: () => _removeItem(
                                                                      consumptionProvider,
                                                                      uci,
                                                                      index),
                                                                  child: ConsumptionItemRow(uci))
                                                          )
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            }
                                          }),
                                        ),
                                      );
                                    }
                                  }),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: AnimatedOpacity(
                                  opacity: _showTopShadow ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.black26, Colors.transparent],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: AnimatedOpacity(
                                  opacity: _showBottomShadow ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.transparent, Colors.black26],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 120,
                    padding: EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      color: HavkaColors.cream,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: _bottomOffset,
                          blurRadius: _bottomBlurRadius,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NutritionInfo(product: widget.fridgeItem!.product, weight: weight!)
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
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
                                          RegExp(r'^(\d+)?[.,]?\d{0,2}'),
                                        ),
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      dropDownItemsList: servingUnitNames,
                                      dropDownInitialValue: servingUnits!.firstWhere((element) => element.valueInBaseUnit > 1).name,
                                      onSelectedDropDownItem: (value) => setState(() {
                                        selectedServingUnit = value;
                                        weightInServing = weightController.text.isEmpty ? 0 : double.parse(weightController.text);
                                        weight = weightInServing * widget.fridgeItem!.product.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit;
                                      }),
                                      trailingText: weightController.text != '' && widget.fridgeItem!.product.serving.firstWhere((element) => element.name == selectedServingUnit).name != widget.fridgeItem!.product.baseUnit
                                          ? "= ${formatNumber(double.parse(weightController.text) * widget.fridgeItem!.product.serving.firstWhere((element) => element.name == selectedServingUnit).valueInBaseUnit)} ${widget.fridgeItem!.product.baseUnit}"
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
                              SubmitButton(
                                text: 'Add',
                                disabled: weightController.text.isEmpty || weight! < 0.0001,
                                onSubmit: () async {
                                  FocusManager.instance.primaryFocus
                                      ?.unfocus();
                                  final Serving selectedServing = widget.fridgeItem!.product.serving.firstWhere((element) => element.name == selectedServingUnit);
                                  final UserConsumptionItem
                                  userConsumptionItem =
                                  UserConsumptionItem(
                                    productId:
                                    widget.fridgeItem!.product.id,
                                    product: widget.fridgeItem!.product,
                                    fridgeItemId: widget.fridgeItem!.id,
                                    consumedAmount: ConsumedAmount(
                                        serving: Serving(
                                            name: selectedServing.name,
                                            valueInBaseUnit: selectedServing.valueInBaseUnit),
                                        value: weightInServing),
                                    consumedAt: selectedDateTime,
                                  );
                                  print(UserConsumptionItemModel.fromDomain(userConsumptionItem));
                                  await _insertItem(consumptionProvider, userConsumptionItem);
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

  Future<void> _insertItem(ConsumptionProvider consumptionProvider, UserConsumptionItem userConsumptionItem) async {
    await consumptionProvider.addConsumption(userConsumptionItem);
    final UserConsumptionItem? newUCI = consumptionProvider.createdConsumptionItem;
    if (Platform.isIOS) {
      _userConsumptionListKeyIOS.currentState?.insertItem(0);
    } else if (Platform.isAndroid) {
      _userConsumptionListKeyAndroid.currentState?.insertItem(0);
    }
    if (newUCI != null) {
      setState(() {
        consumptionProvider.productConsumption.insert(0, newUCI);
      });
    }
  }

  void _removeItem(ConsumptionProvider consumptionProvider, UserConsumptionItem userConsumptionItem, int index) async {
    if (Platform.isIOS) {
      await consumptionProvider.deleteConsumption(userConsumptionItem);
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
                      '${formatNumber(userConsumptionItem.consumedAmount!.value)} ${userConsumptionItem.consumedAmount!.serving.name}',
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
        consumptionProvider.productConsumption.removeAt(index);
      });
    } else if (Platform.isAndroid) {
      await consumptionProvider.deleteConsumption(userConsumptionItem);
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
                        '${formatNumber(userConsumptionItem.consumedAmount!.value)} ${userConsumptionItem.consumedAmount!.serving.name}',
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
        consumptionProvider.productConsumption.removeAt(index);
      });
    }
  }
}
