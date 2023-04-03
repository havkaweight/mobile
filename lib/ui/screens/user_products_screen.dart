import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/havka_barcode_scanner.dart';
import 'package:health_tracker/ui/screens/products_screen.dart';
import 'package:health_tracker/ui/screens/scrolling_behavior.dart';
import 'package:health_tracker/ui/widgets/ble_status_tracking_widget.dart';
import 'package:health_tracker/ui/widgets/fridgeitem.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/modal_scale.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/widgets/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, String>> userProductsList = [];
OverlayEntry? _overlayEntry;

class UserProductsScreen extends StatefulWidget {
  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen>
    with SingleTickerProviderStateMixin {
  final barcodeController = TextEditingController();

  final ApiRoutes _apiRoutes = ApiRoutes();
  late List<UserProduct> userProducts;
  late Widget childWidget;
  late AnimationController _animationController;
  bool isScaleShowed = false;

  void showModalScale() {
    _overlayEntry = OverlayEntry(
        builder: (context) =>
            ModalScale(animationController: _animationController));
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
  }

  @override
  Widget build(BuildContext context) {
    return BleStatusTrackingWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const ScreenHeader(text: 'Fridge'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.monitor_weight,
                        color: HavkaColors.green,
                      ),
                      onPressed: () async {
                        changeModalScaleState();
                        setState(() {
                          isScaleShowed = !isScaleShowed;
                        });
                      },
                    ),
                    RoundedButton(
                      width: 100,
                      text: 'Add havka',
                      onPressed: () {
                        _buildProductsList(context)
                            .then((_) => setState(() {}));
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.barcode,
                          color: HavkaColors.green),
                      onPressed: () {
                        _buildBarcodeScanner().then((_) => setState(() {}));
                      },
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<UserProduct>>(
                future: _apiRoutes.getUserProductsList(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<UserProduct>> snapshot,
                ) {
                  if (!snapshot.hasData) {
                    childWidget = Center(
                      child: getShimmerLoading(),
                    );
                  }
                  if (snapshot.hasData) {
                    userProducts = snapshot.data!;
                    if (userProducts.isNotEmpty) {
                      childWidget = RefreshIndicator(
                        onRefresh: _pullRefresh,
                        child: ScrollConfiguration(
                            behavior: CustomBehavior(),
                            child: ListView.builder(
                              itemCount: userProducts.length,
                              itemBuilder: (BuildContext context, index) {
                                final UserProduct userProduct =
                                    userProducts[index];
                                return FridgeItem(userProduct: userProduct);
                              },
                            )),
                      );
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
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    final newUserProducts = await _apiRoutes.getUserProductsList();
    setState(() {
      userProducts = newUserProducts;
    });
  }

  Future<dynamic> _buildBarcodeScanner() {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).backgroundColor,
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
                  height: mHeight * 0.75, child: HavkaBarcodeScannerScreen()),
        );
      },
    );
  }

  Future<dynamic> _buildProductsList(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).backgroundColor,
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
