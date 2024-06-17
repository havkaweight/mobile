import 'dart:convert';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/constants/fridge_sort.dart';
import 'package:havka/model/data_items.dart';
import 'package:havka/model/fridge_data_model.dart';
import 'package:havka/model/product.dart';
import 'package:havka/model/product_amount.dart';
import 'package:havka/model/profile_data_model.dart';
import 'package:havka/model/user_consumption_item.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:havka/ui/screens/fridge_adjustment_screen.dart';
import 'package:havka/ui/screens/havka_barcode_scanner.dart';
import 'package:havka/ui/screens/havka_receipt_scanner.dart';
import 'package:havka/ui/screens/product_adjustment_screen.dart';
import 'package:havka/ui/screens/products_screen.dart';
import 'package:havka/ui/screens/scrolling_behavior.dart';
import 'package:havka/ui/widgets/fridgeitem.dart';
import 'package:havka/ui/widgets/holder.dart';
import 'package:havka/ui/widgets/modal_scale.dart';
import 'package:havka/ui/widgets/screen_header.dart';
import 'package:havka/ui/widgets/shimmer.dart';
import 'package:havka/ui/widgets/stack_bar_chart.dart';
import 'package:havka/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/utils.dart';
import '../../model/fridge.dart';
import '../widgets/progress_indicator.dart';
import 'authorization.dart';
import 'main_screen.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({Key? key}) : super(key: key);

  @override
  _FridgeScreenState createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen>
    with TickerProviderStateMixin {
  final ApiRoutes _apiRoutes = ApiRoutes();

  final GlobalKey<SliverAnimatedListState> _userProductsListKeyIOS =
      GlobalKey<SliverAnimatedListState>();
  final GlobalKey<AnimatedListState> _userProductsListKeyAndroid =
      GlobalKey<AnimatedListState>();

  late Widget childWidget;
  late List<UserFridge>? userFridges;
  late UserFridge? userFridge;
  late List<PopupMenuEntry<UserFridge>> itemsList;
  late List<UserFridgeItem> userFridgeItems;
  late FridgeDataModel fridgeData;
  late FridgeSort fridgeSort;
  late ValueNotifier<FridgeSort> fridgeSortListener = ValueNotifier(fridgeSort);
  late final AnimationController filterButtonAnimationController;

  @override
  void initState() {
    super.initState();

    filterButtonAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 80),
    );

    fridgeSort = FridgeSort(
      order: FridgeOrder.descending,
    );

    fridgeSortListener.value = fridgeSort;

    itemsList = [];
    _buildContextMenu();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<UserFridgeItem?> _insertItem(Product product) async {
    final FridgeDataModel fridgeData = context.read<FridgeDataModel>();
    final UserFridgeItem? newUserFridgeItem =
        await _apiRoutes.addFridgeItem(fridgeData.mainFridge!, product);

    if (newUserFridgeItem != null) {
      await fridgeData.addUserFridgeItem(
          fridgeData.mainFridge!, newUserFridgeItem);
      if (Platform.isIOS) {
        _userProductsListKeyIOS.currentState?.insertItem(0);
      } else if (Platform.isAndroid) {
        _userProductsListKeyAndroid.currentState?.insertItem(0);
      }
    }
    return newUserFridgeItem;
  }

  void _removeItem(UserFridgeItem userFridgeItem, int index) async {
    final FridgeDataModel fridgeData = context.read<FridgeDataModel>();
    await _apiRoutes.deleteFridgeItem(userFridgeItem);
    await fridgeData.deleteUserFridgeItem(userFridgeItem);
    if (Platform.isIOS) {
      _userProductsListKeyIOS.currentState?.removeItem(index, (_, animation) {
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
              child: FridgeItem(
                userFridgeItem: userFridgeItem,
              ),
            ),
          ),
        );
      });
    } else if (Platform.isAndroid) {
      _userProductsListKeyAndroid.currentState?.removeItem(
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
                child: FridgeItem(
                  userFridgeItem: userFridgeItem,
                ),
              ),
            ),
          );
        },
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  Future<UserFridge?> showContextMenu(BuildContext context) async {
    final RenderBox renderBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final UserFridge? uf = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Offset(0, 100) & renderBox.size,
        Offset(0, 0) & renderBox.size,
      ),
      items: itemsList,
    );

    return uf;
  }

  void _buildContextMenu() {
    fridgeData = context.read<FridgeDataModel>();

    userFridges = fridgeData.fridgeData;
    userFridge = fridgeData.mainFridge;
    userFridgeItems = fridgeData.fridgeItemsData;

    itemsList = [];
    itemsList.add(PopupMenuItem(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Edit"),
          Icon(Icons.edit),
        ],
      ),
      onTap: () async {
        await context.push("/fridge/edit", extra: fridgeData.mainFridge);
        setState(() {});
      },
    ));

    if (userFridges!.length > 1) {
      itemsList.add(PopupMenuDivider());
      userFridges?.forEach((uf) {
        if (uf != fridgeData.mainFridge) {
          itemsList.add(PopupMenuItem(
            value: uf,
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(uf.name),
                Icon(Icons.kitchen),
              ],
            ),
            onTap: () {
              // fridgeData.mainFridge = userFridge;
            },
          ));
        }
      });
    }

    itemsList.add(PopupMenuDivider());

    itemsList.add(PopupMenuItem(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Add fridge'),
          Icon(Icons.add),
        ],
      ),
      onTap: () async {
        UserFridge? uf = await context.push("/fridge/add");
        if (uf == null) {
          return;
        }
        fridgeData.setMainFridge(uf);
        setState(() {
          _buildContextMenu();
        });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              // decoration: BoxDecoration(
              //   color: HavkaColors.cream,
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.05),
              //       offset: Offset(0.0, 2.0),
              //       blurRadius: 1.0,
              //     ),
              //   ],
              // ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Consumer<FridgeDataModel>(
                            builder: (context, userFridges, _) {
                              return AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: userFridges.mainFridge == null
                                      ? Container(
                                          width: 120,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: Colors.black.withOpacity(0.05),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () async {
                                            final UserFridge? uf =
                                                await showContextMenu(context);
                                            if (uf != null) {
                                              await userFridges.setMainFridge(uf);
                                              await _refreshUserProducts();
                                              setState(() {
                                                _buildContextMenu();
                                              });
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              ScreenHeader(
                                                  text: Utils().cutString(
                                                      userFridges.mainFridge!.name,
                                                      10)),
                                              Icon(
                                                Icons.keyboard_arrow_down,
                                                color: HavkaColors.green,
                                              ),
                                            ],
                                          ),
                                        ));
                            },
                          ),
                          Row(
                            children: [
                              TextButton(
                                child: Text("Add havka"),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.black.withOpacity(0.05)),
                                ),
                                onPressed: () async {
                                  final Product? product =
                                      await _buildProductsList(context);
                                  if (product == null) {
                                    return;
                                  }
                                  if (DateTime.now()
                                          .difference(product.createdAt)
                                          .inSeconds <
                                      5) {
                                    await _showAddToFridgeAlert(product);
                                  } else {
                                    await _insertItem(product);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  CupertinoIcons.barcode,
                                  color: HavkaColors.green,
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.black.withOpacity(0.05)),
                                ),
                                onPressed: () async {
                                  final List lst = await _buildBarcodeScanner();
                                  if (lst.firstOrNull == null) {
                                    return;
                                  }
                                  if (lst.lastOrNull == "add") {
                                    final Product product = lst.firstOrNull;
                                    if (DateTime.now()
                                            .difference(product.createdAt)
                                            .inSeconds <
                                        5) {
                                      await _showAddToFridgeAlert(product);
                                    } else {
                                      await _insertItem(product);
                                    }
                                  } else if (lst.lastOrNull == "consume") {
                                    final Product product = lst.firstOrNull;
                                    final FridgeDataModel fridgeData =
                                        context.read<FridgeDataModel>();
                                    final UserFridgeItem? ufi =
                                        await _apiRoutes.addFridgeItem(
                                            fridgeData.mainFridge!, product);
                                    ufi!.product!.serving.sort((a, b) => b
                                        .valueInBaseUnit
                                        .compareTo(a.valueInBaseUnit));
                                    final UserConsumptionItem uci =
                                        UserConsumptionItem(
                                      productId: ufi.product!.id,
                                      product: ufi.product,
                                      userFridgeItem: ufi,
                                      fridgeItemId: ufi.id,
                                      consumedAt: DateTime.now(),
                                      consumedAmount: ConsumedAmount(
                                          serving: ufi.product!.serving.firstWhere(
                                              (element) =>
                                                  ufi.amount!.value! -
                                                      (ufi.amount!.value! ~/
                                                              element
                                                                  .valueInBaseUnit) *
                                                          element.valueInBaseUnit <
                                                  0.00001),
                                          value: ufi.amount!.value! /
                                              ufi.product!.serving
                                                  .firstWhere((element) =>
                                                      ufi.amount!.value! -
                                                          (ufi.amount!.value! ~/
                                                                  element
                                                                      .valueInBaseUnit) *
                                                              element
                                                                  .valueInBaseUnit <
                                                      0.00001)
                                                  .valueInBaseUnit),
                                    );
                                    await _apiRoutes.addUserConsumptionItem(
                                        userConsumptionItem: uci);
                                    await _apiRoutes.deleteFridgeItem(ufi);
                                    await fridgeData.deleteUserFridgeItem(ufi);
                                  } else if (lst.lastOrNull == "create") {
                                    final Product? createdProduct = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductAdjustmentScreen(
                                                  barcode: lst.firstOrNull,
                                                )));
                                    await _showAddToFridgeAlert(createdProduct!);
                                  }
                                },
                              ),
                              // IconButton(
                              //   icon: const Icon(
                              //     Icons.receipt_long,
                              //     color: HavkaColors.green,
                              //   ),
                              //   style: ButtonStyle(
                              //     backgroundColor: MaterialStatePropertyAll(
                              //         Colors.black.withOpacity(0.05)),
                              //   ),
                              //   onPressed: () async {
                              //     await _buildReceiptScanner();
                              //   },
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Consumer<FridgeDataModel>(
                      builder: (
                          BuildContext context,
                          fridge,
                          _,
                          ) {
                        final List<PFCDataItem>? nutritionFacts =
                            fridge.fridgeNutrition;
                        if (nutritionFacts == null) {
                          return Container();
                        }
                        return HavkaStackBarChart(
                          initialData: nutritionFacts
                              .where((element) => element.value > 0.0)
                              .toList(),
                          onTapBar: (key) {
                            switch (key) {
                              case 0:
                                fridgeSort.filterBy = FridgeFilter.protein;
                              case 1:
                                fridgeSort.filterBy = FridgeFilter.fat;
                              case 2:
                                fridgeSort.filterBy = FridgeFilter.carbs;
                              default:
                                fridgeSort.filterBy = null;
                            }
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  Consumer<FridgeDataModel>(builder: (
                      BuildContext context,
                      userFridgeItems,
                      _,
                      ) {
                    return Container(
                      margin: const EdgeInsets.only(
                        left: 30.0,
                        right: 30.0,
                        bottom: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          userFridgeItems.fridgeItemsData.length > 0
                              ? const Text(
                            "Groceries",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : SizedBox.shrink(),
                          userFridgeItems.fridgeItemsData.length > 1
                              ? ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 0.9).animate(filterButtonAnimationController),
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                if(details.delta.dx.abs() > 1 || details.delta.dy.abs() > 1) {
                                  filterButtonAnimationController.reverse();
                                }
                              },
                              onTapDown: (details) {
                                filterButtonAnimationController.forward();
                              },
                              onTapUp: (details) {
                                filterButtonAnimationController.reverse();
                                switch (fridgeSort.order) {
                                  case FridgeOrder.descending:
                                    fridgeSort.order = FridgeOrder.ascending;
                                  case FridgeOrder.ascending:
                                    fridgeSort.order = FridgeOrder.descending;
                                  default:
                                    fridgeSort.order = FridgeOrder.descending;
                                }
                                setState(() {});
                              },
                              child: ValueListenableBuilder(
                                  valueListenable: fridgeSortListener,
                                  builder: (context, value, _) {
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: value.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 5.0),
                                            child: Icon(
                                              Icons.sort,
                                              size: 15,
                                              color: value.color,
                                            ),
                                          ),
                                          Text(
                                            fridgeSort.text,
                                            style: TextStyle(
                                              color: value.color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          )
                              : SizedBox.shrink(),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Consumer<FridgeDataModel>(
                builder: (
                  BuildContext context,
                  userFridgeItems,
                  _,
                ) {
                  if (!userFridgeItems.isLoaded) {
                    childWidget = Center(
                      child: getShimmerLoading(),
                    );
                  } else {
                    if (userFridgeItems.fridgeItemsData.isNotEmpty) {
                      final fridgeItemsData =
                          userFridgeItems.fridgeItemsData.sorted((a, b) {
                        switch (fridgeSort.filterBy) {
                          case FridgeFilter.protein:
                            if (fridgeSort.order == FridgeOrder.descending) {
                              return (b.product!.nutrition!.protein!.total!/b.product!.nutrition!.valuePerInBaseUnit!*100)
                                  .compareTo(
                                  (a.product!.nutrition!.protein!.total!/a.product!.nutrition!.valuePerInBaseUnit!*100));
                            } else {
                              return (a.product!.nutrition!.protein!.total!/a.product!.nutrition!.valuePerInBaseUnit!*100)
                                  .compareTo(
                                  (b.product!.nutrition!.protein!.total!/b.product!.nutrition!.valuePerInBaseUnit!*100));
                            }
                          case FridgeFilter.fat:
                            if (fridgeSort.order == FridgeOrder.descending) {
                              return (b.product!.nutrition!.fat!.total!/b.product!.nutrition!.valuePerInBaseUnit!*100)
                                  .compareTo((a.product!.nutrition!.fat!.total!/a.product!.nutrition!.valuePerInBaseUnit!*100));
                            } else {
                              return (a.product!.nutrition!.fat!.total!/a.product!.nutrition!.valuePerInBaseUnit!*100)
                                  .compareTo((b.product!.nutrition!.fat!.total!/b.product!.nutrition!.valuePerInBaseUnit!*100));
                            }
                          case FridgeFilter.carbs:
                            if (fridgeSort.order == FridgeOrder.descending) {
                              return (b.product!.nutrition!.carbs!.total!/b.product!.nutrition!.valuePerInBaseUnit!*100)
                                  .compareTo(
                                  (a.product!.nutrition!.carbs!.total!/a.product!.nutrition!.valuePerInBaseUnit!*100));
                            } else {
                              return (a.product!.nutrition!.carbs!.total!/a.product!.nutrition!.valuePerInBaseUnit!*100)
                                  .compareTo(
                                  (b.product!.nutrition!.carbs!.total!/b.product!.nutrition!.valuePerInBaseUnit!*100));
                            }
                          default:
                            if (fridgeSort.order == FridgeOrder.descending) {
                              return b.createdAt.compareTo(a.createdAt);
                            } else {
                              return a.createdAt.compareTo(b.createdAt);
                            }
                        }
                      });
                      if (Platform.isAndroid) {
                        childWidget = RefreshIndicator(
                          onRefresh: _refreshUserProducts,
                          child: ScrollConfiguration(
                            behavior: CustomBehavior(),
                            child: Scrollbar(
                              controller: fridgeItemsListScrollController,
                              child: AnimatedList(
                                key: _userProductsListKeyAndroid,
                                controller: fridgeItemsListScrollController,
                                initialItemCount: fridgeItemsData.length,
                                itemBuilder:
                                    (BuildContext context, index, animation) {
                                  final UserFridgeItem userFridgeItem =
                                      fridgeItemsData[index];
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: animation,
                                      child: FridgeItem(
                                        userFridgeItem: userFridgeItem,
                                        onContextMenuDelete: () =>
                                            _removeItem(userFridgeItem, index),
                                        onContextMenuDuplicate: () {
                                          _insertItem(userFridgeItem.product!);
                                        },
                                        onContextMenuEatWhole: () async {
                                          userFridgeItem.product!.serving.sort(
                                              (a, b) => b.valueInBaseUnit
                                                  .compareTo(a.valueInBaseUnit));
                                          final UserConsumptionItem uci =
                                              UserConsumptionItem(
                                            productId: userFridgeItem.product!.id,
                                            product: userFridgeItem.product!,
                                            userFridgeItem: userFridgeItem,
                                            fridgeItemId: userFridgeItem.id,
                                            consumedAt: DateTime.now(),
                                            consumedAmount: ConsumedAmount(
                                                serving: userFridgeItem.product!.serving
                                                    .firstWhere((element) =>
                                                        userFridgeItem.amount!.value! -
                                                            (userFridgeItem.amount!.value! ~/ element.valueInBaseUnit) *
                                                                element
                                                                    .valueInBaseUnit <
                                                        0.00001),
                                                value: userFridgeItem.amount!.value! /
                                                    userFridgeItem.product!.serving
                                                        .firstWhere((element) =>
                                                            userFridgeItem.amount!.value! -
                                                                (userFridgeItem.amount!.value! ~/ element.valueInBaseUnit) *
                                                                    element.valueInBaseUnit <
                                                            0.00001)
                                                        .valueInBaseUnit),
                                          );
                                          await _apiRoutes.addUserConsumptionItem(
                                              userConsumptionItem: uci);
                                          _removeItem(userFridgeItem, index);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      } else {
                        childWidget = Scrollbar(
                          controller: fridgeItemsListScrollController,
                          child: CustomScrollView(
                            controller: fridgeItemsListScrollController,
                            slivers: [
                              CupertinoSliverRefreshControl(
                                onRefresh: _refreshUserProducts,
                              ),
                              SliverAnimatedList(
                                key: _userProductsListKeyIOS,
                                initialItemCount: fridgeItemsData.length,
                                itemBuilder: (context, index, animation) {
                                  final UserFridgeItem userFridgeItem =
                                      fridgeItemsData[index];
                                  return SizeTransition(
                                    sizeFactor: animation,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: FridgeItem(
                                        userFridgeItem: userFridgeItem,
                                        onContextMenuDelete: () =>
                                            _removeItem(userFridgeItem, index),
                                        onContextMenuDuplicate: () {
                                          _insertItem(userFridgeItem.product!);
                                        },
                                        onContextMenuEatWhole: () async {
                                          userFridgeItem.product!.serving.sort(
                                              (a, b) => b.valueInBaseUnit
                                                  .compareTo(
                                                      a.valueInBaseUnit));
                                          final UserConsumptionItem uci =
                                              UserConsumptionItem(
                                            productId:
                                                userFridgeItem.product!.id,
                                            product: userFridgeItem.product!,
                                            userFridgeItem: userFridgeItem,
                                            fridgeItemId: userFridgeItem.id,
                                            consumedAt: DateTime.now(),
                                            consumedAmount: ConsumedAmount(
                                                serving: userFridgeItem
                                                    .product!.serving
                                                    .firstWhere((element) =>
                                                        userFridgeItem.amount!.value! -
                                                            (userFridgeItem.amount!.value! ~/ element.valueInBaseUnit) *
                                                                element
                                                                    .valueInBaseUnit <
                                                        0.00001),
                                                value: userFridgeItem.amount!.value! /
                                                    userFridgeItem.product!.serving
                                                        .firstWhere((element) =>
                                                            userFridgeItem.amount!.value! -
                                                                (userFridgeItem.amount!.value! ~/ element.valueInBaseUnit) * element.valueInBaseUnit <
                                                            0.00001)
                                                        .valueInBaseUnit),
                                          );
                                          await _apiRoutes
                                              .addUserConsumptionItem(
                                                  userConsumptionItem: uci);
                                          _removeItem(userFridgeItem, index);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      childWidget = Center(child: Text("Fridge is empty"));
                    }
                  }
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: childWidget,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshUserProducts() async {
    await context.read<FridgeDataModel>().initData();
  }

  Future<List<dynamic>> _buildBarcodeScanner() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription firstCamera = cameras.first;
    final List lst = await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
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
              isProduct: true,
            ),
          ),
        );
      },
    );
    return lst;
  }

  Future<dynamic> _buildReceiptScanner() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription firstCamera = cameras.first;
    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
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
            child: HavkaReceiptScannerScreen(camera: firstCamera),
          ),
        );
      },
    );
  }

  Future<Product?> _buildProductsList(BuildContext context) async {
    final Product? product = await showModalBottomSheet<Product?>(
      useRootNavigator: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => ProductsScreen(),
    );
    return product;
  }

  Future<void> _showAddToFridgeAlert(Product product) async {
    return showDialog(
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: Text("Wanna add to your fridge?"),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      context.pop();
                      await _insertItem(product);
                    },
                  ),
                ],
              )
            : AlertDialog(
                title: Text("Wanna add to your fridge?"),
                actions: [
                  TextButton(
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  TextButton(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      context.pop();
                      await _insertItem(product);
                    },
                  ),
                ],
              );
      },
    );
  }
}
