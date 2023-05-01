import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_consumption_item.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/havka_barcode_scanner.dart';
import 'package:health_tracker/ui/screens/products_screen.dart';
import 'package:health_tracker/ui/screens/scrolling_behavior.dart';
import 'package:health_tracker/ui/widgets/fridgeitem.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/modal_scale.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/widgets/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, String>> userProductsList = [];
OverlayEntry? _overlayEntry;

enum SortingType { dateAddedAsc, dateAddedDesc }

String? barcode;

typedef DeleteUserProductCallback = Future<void> Function(UserProduct);

class UserProductsScreen extends StatefulWidget {
  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen>
    with SingleTickerProviderStateMixin {
  final barcodeController = TextEditingController();
  late Icon sortIcon;
  SortingType sortingType = SortingType.dateAddedDesc;

  final ApiRoutes _apiRoutes = ApiRoutes();
  late List<UserProduct> userProducts;
  late List<UserConsumptionItem>? userConsumption;
  ValueNotifier<List<UserProduct>?> userProductsListener = ValueNotifier(null);
  late Widget childWidget;
  late AnimationController _animationController;
  bool isScaleShowed = false;

  void showModalScale() {
    _overlayEntry = OverlayEntry(
      builder: (context) => ModalScale(
        animationController: _animationController,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void hideModalScale() {
    _animationController.reverse().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> changeModalScaleState() async {
    final prefs = await SharedPreferences.getInstance();
    isScaleShowed = prefs.getBool('isScaleShowed') ?? false;
    if (isScaleShowed) {
      hideModalScale();
    } else {
      showModalScale();
    }
    prefs.setBool('isScaleShowed', !isScaleShowed);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    sortIcon = const Icon(Icons.south);
    () async {
      await _apiRoutes.getMe();
      await fetchUserConsumption();
      userProducts = await _apiRoutes.getUserProductsList();
      _sortList();
      userProductsListener.value = userProducts;
    }();
  }

  Future<void> fetchUserConsumption() async {
    const String fileName = "userConsumption.json";
    final dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      final jsonData = jsonDecode(file.readAsStringSync()) as List;
      final List<UserConsumptionItem> newUserConsumption =
          jsonData.map<UserConsumptionItem>(
        (json) {
          return UserConsumptionItem.fromJson(json as Map<String, dynamic>);
        },
      ).toList();
      userConsumption = newUserConsumption;
    }
    userConsumption = await _apiRoutes.getUserConsumption();
    file.writeAsStringSync(
      jsonEncode(
        [for (UserConsumptionItem uci in userConsumption!) uci.toJson()],
      ),
      flush: true,
    );
  }

  void _sortList() {
    switch (sortingType) {
      case SortingType.dateAddedAsc:
        sortIcon = const Icon(Icons.north);
        userProducts.sort(
          (prev, next) => next.createdAt!.compareTo(prev.createdAt!),
        );
        break;
      case SortingType.dateAddedDesc:
        sortIcon = const Icon(Icons.south);
        userProducts.sort(
          (prev, next) => prev.createdAt!.compareTo(next.createdAt!),
        );
        break;
    }
  }

  void _removeItem(UserProduct userProduct, int index, BuildContext context) {
    _apiRoutes.deleteUserProduct(userProduct).whenComplete(() {
      AnimatedList.of(context).removeItem(
        index,
        (_, animation) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(animation),
              child: FridgeItem(
                userProduct: userProduct,
                userConsumption: userConsumption!
                    .where(
                      (element) =>
                          element.product!.id == userProduct.product!.id,
                    )
                    .toList(),
              ),
            ),
          );
        },
        duration: const Duration(milliseconds: 200),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const ScreenHeader(text: 'Fridge'),
              Row(
                children: [
                  RoundedButton(
                    text: 'Add havka',
                    onPressed: () {
                      _buildProductsList(context).then((_) => setState(() {}));
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.barcode,
                      color: HavkaColors.green,
                    ),
                    onPressed: () {
                      _buildBarcodeScanner().then((_) => setState(() {}));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Groceries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: sortIcon,
                    onPressed: () {
                      if (sortIcon.icon == Icons.south) {
                        sortingType = SortingType.dateAddedAsc;
                      } else {
                        sortingType = SortingType.dateAddedDesc;
                      }
                      _sortList();
                      setState(() {});
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: userProductsListener,
            builder: (
              BuildContext context,
              List<UserProduct>? value,
              _,
            ) {
              if (value == null) {
                childWidget = Center(
                  child: getShimmerLoading(),
                );
              }
              if (value != null) {
                if (value.isNotEmpty) {
                  if (Platform.isAndroid) {
                    childWidget = RefreshIndicator(
                      onRefresh: _refreshUserProducts,
                      child: ScrollConfiguration(
                        behavior: CustomBehavior(),
                        child: AnimatedList(
                          initialItemCount: value.length,
                          itemBuilder:
                              (BuildContext context, index, animation) {
                            final UserProduct userProduct = value[index];
                            return FridgeItem(
                              userProduct: userProduct,
                              userConsumption: userConsumption!
                                  .where(
                                    (element) =>
                                        element.product!.id ==
                                        value[index].product!.id,
                                  )
                                  .toList(),
                              onPressed: () {
                                _removeItem(userProduct, index, context);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    childWidget = CustomScrollView(
                      slivers: [
                        CupertinoSliverRefreshControl(
                          onRefresh: _refreshUserProducts,
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final UserProduct userProduct = value[index];
                              return FridgeItem(
                                userProduct: userProduct,
                                userConsumption: userConsumption!
                                    .where(
                                      (element) =>
                                          element.product!.id ==
                                          value[index].product!.id,
                                    )
                                    .toList(),
                                onPressed: () {
                                  _apiRoutes
                                      .deleteUserProduct(userProduct)
                                      .whenComplete(() {
                                    setState(() {
                                      value.removeAt(index);
                                    });
                                  });
                                },
                              );
                            },
                            childCount: value.length,
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  childWidget = const Center(child: Text("No items found"));
                }
              }
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: childWidget,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _refreshUserProducts() async {
    userProducts = await _apiRoutes.getUserProductsList();
    _sortList();
    userProductsListener.value = userProducts;
  }

  Future<dynamic> _buildBarcodeScanner() {
    return showModalBottomSheet(
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child:
              // SizedBox(height: mHeight * 0.75, child: BarcodeScannerScreen()),
              SizedBox(
            height: mHeight * 0.75,
            child: const HavkaBarcodeScannerScreen(
              isProduct: true,
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _buildProductsList(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              Holder(),
              Column(
                children: [
                  ProductsScreen(),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
