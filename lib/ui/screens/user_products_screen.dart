import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/products_screen.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/user_product_screen.dart';
import 'package:health_tracker/ui/widgets/ble_status_tracking_widget.dart';
import 'package:health_tracker/ui/widgets/fridgeitem.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/shimmer.dart';
import 'barcode_scanner.dart';

List<Map<String, String>> userProductsList = [];

class UserProductsScreen extends StatefulWidget {
  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class CustomBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child;
  }
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  final barcodeController = TextEditingController();

  final ApiRoutes _apiRoutes = ApiRoutes();
  late List<UserProduct> userProducts;
  late Widget childWidget;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BleStatusTrackingWidget(
      child: Column(
        children: <Widget>[
          Row(
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
                    icon: const FaIcon(FontAwesomeIcons.barcode, color: HavkaColors.green),
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
                  childWidget = RefreshIndicator(
                    onRefresh: _pullRefresh,
                    child: ScrollConfiguration(
                      behavior: CustomBehavior(),
                      child: ListView.builder(
                        itemCount: userProducts.length,
                        itemBuilder: (BuildContext context, index) {
                          final UserProduct userProduct = userProducts[index];
                          return FridgeItem(userProduct: userProduct);
                        },
                      )
                    ),
                  );
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
              SizedBox(height: mHeight * 0.75, child: BarcodeScannerScreen()),
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
      builder: (BuildContext builder) {
        final double mHeight = MediaQuery.of(context).size.height;
        return SizedBox(
          height: mHeight * 0.85,
          child: Column(
            children: [
              Holder(),
              Center(
                child: Column(
                  children: [
                    ProductsScreen(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
