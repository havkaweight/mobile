import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/data/models/fridge/user_fridge_model.dart';
import 'package:havka/presentation/providers/consumption_provider.dart';
import 'package:havka/presentation/widgets/sort_button.dart';
import '../../data/models/pfc_data_item.dart';
import '../../domain/entities/consumption/consumed_amount.dart';
import '../../domain/entities/product/fridge_item.dart';
import '../providers/fridge_provider.dart';
import '../widgets/charts/stack_bar_chart.dart';
import '/core/constants/colors.dart';
import '../../domain/entities/product/product.dart';
import '../../domain/entities/consumption/user_consumption_item.dart';
import '/presentation/screens/havka_barcode_scanner.dart';
import '/presentation/screens/havka_receipt_scanner.dart';
import '/presentation/screens/product_adjustment_screen.dart';
import '/presentation/screens/products_screen.dart';
import '/presentation/screens/scrolling_behavior.dart';
import '/presentation/widgets/fridge_item_row.dart';
import '/presentation/widgets/screen_header.dart';
import '/presentation/widgets/shimmer.dart';
import 'package:provider/provider.dart';
import '/core/constants/utils.dart';
import '/domain/entities/fridge/user_fridge.dart';
import 'main_screen.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({Key? key}) : super(key: key);

  @override
  _FridgeScreenState createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<SliverAnimatedListState> _userProductsListKeyIOS =
      GlobalKey<SliverAnimatedListState>();
  final GlobalKey<AnimatedListState> _userProductsListKeyAndroid =
      GlobalKey<AnimatedListState>();

  late Widget childWidget;
  late List<UserFridge>? userFridges;
  late UserFridge? userFridge;
  late List<PopupMenuEntry<UserFridge>> itemsList;
  late List<FridgeItem> fridgeItems;
  late final AnimationController filterButtonAnimationController;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final FridgeProvider fridgeProvider = context.read<FridgeProvider>();
      await fridgeProvider.fetchUserFridges();
      await fridgeProvider
          .setCurrentUserFridge(fridgeProvider.userFridges.first);
      await fridgeProvider.fetchFridgeItems();

      _buildContextMenu(fridgeProvider);
    });

    filterButtonAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 80),
    );

    itemsList = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<UserFridge?> showContextMenu(BuildContext context, fridgeProvider) async {
    final RenderBox renderBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    setState(() {
      _buildContextMenu(fridgeProvider);
    });

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

  void _buildContextMenu(FridgeProvider fridgeProvider) {
    itemsList = [];
    itemsList.add(PopupMenuItem(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Edit"),
          Icon(Icons.edit),
        ],
      ),
      onTap: () async {
        await context.push("/fridge/edit",
            extra: fridgeProvider.currentUserFridge);
        setState(() {});
      },
    ));

    itemsList.add(PopupMenuItem(
      height: 40,
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
        fridgeProvider.setCurrentUserFridge(uf);
        setState(() {
          _buildContextMenu(fridgeProvider);
        });
      },
    ));

    if (fridgeProvider.userFridges.length > 1) {
      itemsList.add(PopupMenuDivider());
      fridgeProvider.userFridges.forEach((uf) {
        if (uf != fridgeProvider.currentUserFridge) {
          itemsList.add(PopupMenuItem(
            value: uf,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(uf.name),
                Icon(Icons.kitchen),
              ],
            ),
            onTap: () {
              fridgeProvider.setCurrentUserFridge(uf);
            },
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final FridgeProvider fridgeProvider = Provider.of<FridgeProvider>(context);
    final ConsumptionProvider consumptionProvider =
        Provider.of<ConsumptionProvider>(context);
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
                      child: Consumer<FridgeProvider>(
                          builder: (context, fridgeProvider, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                child: fridgeProvider.isLoading || fridgeProvider
                                    .currentUserFridge ==
                                    null
                                    ? Container(
                                        width: 120,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                        ),
                                      )
                                    : Consumer<FridgeProvider>(
                                      builder: (context, fridgeProvider, child) {
                                        return GestureDetector(
                                            onTap: () async {
                                              final UserFridge? uf =
                                                  await showContextMenu(context, fridgeProvider);
                                              if (uf != null) {
                                                fridgeProvider
                                                    .setCurrentUserFridge(uf);
                                                await _refreshFridgeItems(
                                                    fridgeProvider);
                                                setState(() {
                                                  _buildContextMenu(fridgeProvider);
                                                });
                                              }
                                            },
                                            child: Row(
                                                    children: [
                                                      ScreenHeader(
                                                          text: Utils().cutString(
                                                              fridgeProvider
                                                                  .currentUserFridge!
                                                                  .name,
                                                              10)),
                                                      Icon(
                                                        Icons.keyboard_arrow_down,
                                                        color: HavkaColors.green,
                                                      ),
                                                    ],
                                                  ),
                                          );
                                      }
                                    )),
                            Row(
                              children: [
                                TextButton(
                                  child: Text("Add havka"),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.black.withValues(alpha: 0.05)),
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
                                      await _showAddToFridgeAlert(
                                          fridgeProvider, product);
                                    } else {
                                      await fridgeProvider.createFridgeItem(
                                          userFridge!.fridgeId, product.id!);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.barcode_viewfinder,
                                    color: HavkaColors.green,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.black.withValues(alpha: 0.05)),
                                  ),
                                  onPressed: () async {
                                    final List lst =
                                        await _buildBarcodeScanner();
                                    if (lst.firstOrNull == null) {
                                      return;
                                    }
                                    if (lst.lastOrNull == "add") {
                                      final Product product = lst.firstOrNull;
                                      if (DateTime.now()
                                              .difference(product.createdAt)
                                              .inSeconds <
                                          5) {
                                        await _showAddToFridgeAlert(
                                            fridgeProvider, product);
                                      } else {
                                        await fridgeProvider.createFridgeItem(
                                            userFridge!.fridgeId, product.id!);
                                      }
                                    } else if (lst.lastOrNull == "consume") {
                                      final Product product = lst.firstOrNull;
                                      await fridgeProvider.createFridgeItem(
                                        fridgeProvider
                                            .currentUserFridge!.fridgeId,
                                        product.id!,
                                      );
                                      fridgeProvider
                                          .createdFridgeItem!.product.serving
                                          .sort((a, b) => b.valueInBaseUnit
                                              .compareTo(a.valueInBaseUnit));
                                      final consumedAmount = ConsumedAmount(
                                          serving: fridgeProvider
                                              .createdFridgeItem!
                                              .product
                                              .serving
                                              .firstWhere((element) =>
                                                  fridgeProvider
                                                          .createdFridgeItem!
                                                          .amount
                                                          .value -
                                                      (fridgeProvider.createdFridgeItem!.amount.value ~/ element.valueInBaseUnit) *
                                                          element
                                                              .valueInBaseUnit <
                                                  0.00001),
                                          value: fridgeProvider
                                                  .createdFridgeItem!
                                                  .amount
                                                  .value /
                                              fridgeProvider.createdFridgeItem!
                                                  .product.serving
                                                  .firstWhere((element) => fridgeProvider.createdFridgeItem!.amount.value - (fridgeProvider.createdFridgeItem!.amount.value ~/ element.valueInBaseUnit) * element.valueInBaseUnit < 0.00001)
                                                  .valueInBaseUnit);
                                      final UserConsumptionItem uci =
                                          UserConsumptionItem(
                                        productId: fridgeProvider
                                            .createdFridgeItem!.product.id,
                                        product: fridgeProvider
                                            .createdFridgeItem!.product,
                                        fridgeItem:
                                            fridgeProvider.createdFridgeItem!,
                                        fridgeItemId: fridgeProvider
                                            .createdFridgeItem!.id,
                                        consumedAt: DateTime.now(),
                                        consumedAmount: consumedAmount,
                                      );
                                      consumptionProvider.addConsumption(uci);
                                      fridgeProvider.deleteFridgeItem(
                                          fridgeProvider.createdFridgeItem!);
                                    } else if (lst.lastOrNull == "create") {
                                      final Product? createdProduct =
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductAdjustmentScreen(
                                                        barcode:
                                                            lst.firstOrNull,
                                                      )));
                                      if (createdProduct == null) return;
                                      await _showAddToFridgeAlert(fridgeProvider, createdProduct);
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
                        );
                      }),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Consumer<FridgeProvider>(
                      builder: (
                        BuildContext context,
                        fridgeProvider,
                        _,
                      ) {
                        final List<PFCDataItem>? fridgeNutrition =
                            fridgeProvider.getFridgeNutrition();
                        if (fridgeProvider.isFridgeItemsLoading) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          );
                        }
                        if (fridgeNutrition == null) {
                          return Container();
                        }
                        return HavkaStackBarChart(
                          initialData: fridgeNutrition
                              .where((element) => element.value > 0.0)
                              .where((element) => element.value > 0.0)
                              .toList(),
                          onTapBar: (key) {
                            switch (key) {
                              case 0:
                                fridgeProvider
                                    .setSortType(ProductSortType.protein);
                                break;
                              case 1:
                                fridgeProvider.setSortType(ProductSortType.fat);
                                break;
                              case 2:
                                fridgeProvider
                                    .setSortType(ProductSortType.carbs);
                                break;
                              default:
                                fridgeProvider.resetSortType();
                                break;
                            }
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  Consumer<FridgeProvider>(builder: (
                    BuildContext context,
                    fridgeProvider,
                    _,
                  ) {
                    return Container(
                      margin: const EdgeInsets.only(
                        left: 30.0,
                        right: 30.0,
                        bottom: 10.0,
                      ),
                      child: fridgeProvider.fridgeItems.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(
                                    "Groceries",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SortButton(),
                                ])
                          : SizedBox.shrink(),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Consumer<FridgeProvider>(
                builder: (
                  context,
                  fridgeProvider,
                  _,
                ) {
                  if (fridgeProvider.isFridgeItemsLoading) {
                    return Center(child: getShimmerLoading());
                  }
                  if (fridgeProvider.fridgeItems.isEmpty) {
                    return Center(child: Text('Fridge is empty'));
                  }
                  if (Platform.isAndroid) {
                    return RefreshIndicator(
                      onRefresh: () => _refreshFridgeItems(fridgeProvider),
                      child: ScrollConfiguration(
                        behavior: CustomBehavior(),
                        child: Scrollbar(
                          controller: fridgeItemsListScrollController,
                          child: AnimatedList(
                            key: fridgeProvider.fridgeItemsAndroidListKey,
                            controller: fridgeItemsListScrollController,
                            initialItemCount: fridgeProvider.fridgeItems.length,
                            itemBuilder:
                                (BuildContext context, index, animation) {
                              final FridgeItem fridgeItem =
                                  fridgeProvider.fridgeItems[index];
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  child: FridgeItemRow(
                                    fridgeItem: fridgeItem,
                                    onContextMenuDelete: () async =>
                                        fridgeProvider
                                            .deleteFridgeItem(fridgeItem),
                                    onContextMenuDuplicate: () {
                                      fridgeProvider.createFridgeItem(
                                          userFridge!.fridgeId,
                                          fridgeItem.product.id!);
                                    },
                                    onContextMenuEatWhole: () async {
                                      fridgeItem.product.serving.sort((a, b) =>
                                          b.valueInBaseUnit
                                              .compareTo(a.valueInBaseUnit));
                                      final consumedAmount = ConsumedAmount(
                                          serving: fridgeItem.product.serving.firstWhere((element) =>
                                              fridgeItem.amount.value -
                                                  (fridgeItem.amount.value ~/
                                                          element
                                                              .valueInBaseUnit) *
                                                      element.valueInBaseUnit <
                                              0.00001),
                                          value: fridgeItem.amount.value /
                                              fridgeItem.product.serving
                                                  .firstWhere((element) =>
                                                      fridgeItem.amount.value -
                                                          (fridgeItem.amount.value ~/
                                                                  element.valueInBaseUnit) *
                                                              element.valueInBaseUnit <
                                                      0.00001)
                                                  .valueInBaseUnit);
                                      final UserConsumptionItem uci =
                                          UserConsumptionItem(
                                        productId: fridgeItem.product.id,
                                        product: fridgeItem.product,
                                        fridgeItem: fridgeItem,
                                        fridgeItemId: fridgeItem.id,
                                        consumedAt: DateTime.now(),
                                        consumedAmount: consumedAmount,
                                      );
                                      consumptionProvider.addConsumption(uci);
                                      await fridgeProvider
                                          .deleteFridgeItem(fridgeItem);
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
                    return Scrollbar(
                      controller: fridgeItemsListScrollController,
                      child: CustomScrollView(
                        controller: fridgeItemsListScrollController,
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () =>
                                _refreshFridgeItems(fridgeProvider),
                          ),
                          SliverAnimatedList(
                            key: fridgeProvider.fridgeItemsIOSListKey,
                            initialItemCount: fridgeProvider.fridgeItems.length,
                            itemBuilder: (context, index, animation) {
                              final FridgeItem fridgeItem =
                                  fridgeProvider.fridgeItems[index];
                              return SizeTransition(
                                sizeFactor: animation,
                                child: Material(
                                  color: Colors.transparent,
                                  child: FridgeItemRow(
                                    fridgeItem: fridgeItem,
                                    onContextMenuDelete: () async =>
                                        await fridgeProvider
                                            .deleteFridgeItem(fridgeItem),
                                    onContextMenuDuplicate: () async =>
                                        await fridgeProvider.createFridgeItem(
                                            userFridge!.fridgeId,
                                            fridgeItem.product.id!),
                                    onContextMenuEatWhole: () async {
                                      fridgeItem.product.serving.sort((a, b) =>
                                          b.valueInBaseUnit
                                              .compareTo(a.valueInBaseUnit));
                                      final consumedAmount = ConsumedAmount(
                                          serving: fridgeItem.product.serving.firstWhere((element) =>
                                              fridgeItem.amount.value -
                                                  (fridgeItem.amount.value ~/
                                                          element
                                                              .valueInBaseUnit) *
                                                      element.valueInBaseUnit <
                                              0.00001),
                                          value: fridgeItem.amount.value /
                                              fridgeItem.product.serving
                                                  .firstWhere((element) =>
                                                      fridgeItem.amount.value -
                                                          (fridgeItem.amount.value ~/
                                                                  element.valueInBaseUnit) *
                                                              element.valueInBaseUnit <
                                                      0.00001)
                                                  .valueInBaseUnit);
                                      final UserConsumptionItem uci =
                                          UserConsumptionItem(
                                        productId: fridgeItem.product.id,
                                        product: fridgeItem.product,
                                        fridgeItem: fridgeItem,
                                        fridgeItemId: fridgeItem.id,
                                        consumedAt: DateTime.now(),
                                        consumedAmount: consumedAmount,
                                      );
                                      consumptionProvider.addConsumption(uci);
                                      await fridgeProvider
                                          .deleteFridgeItem(fridgeItem);
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshFridgeItems(FridgeProvider fridgeProvider) async {
    fridgeProvider.fetchFridgeItems();
  }

  Future<List<dynamic>> _buildBarcodeScanner() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription firstCamera = cameras.first;
    final List lst = await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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

  Future<void> _showAddToFridgeAlert(
      FridgeProvider fridgeProvider, Product product) async {
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
                      await fridgeProvider.createFridgeItem(
                          userFridge!.fridgeId, product.id!);
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
                      await fridgeProvider.createFridgeItem(
                          userFridge!.fridgeId, product.id!);
                    },
                  ),
                ],
              );
      },
    );
  }
}
