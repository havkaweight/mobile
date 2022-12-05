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

import 'barcode_scanner.dart';

List<Map<String, String>> userProductsList = [];

class UserProductsScreen extends StatefulWidget {
  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  final barcodeController = TextEditingController();

  final ApiRoutes _apiRoutes = ApiRoutes();

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
                    icon: const Icon(Icons.qr_code_2, color: HavkaColors.green),
                    onPressed: () {
                      _buildBarcodeScanner().then((_) => setState(() {}));
                    },
                  ),
                  // RoundedIconButton(
                  //     faIcon: FaIcon(
                  //       FontAwesomeIcons.barcode,
                  //       color: Color(0xFFFFFFFF),
                  //     ),
                  //     onPressed: () => _apiRoutes.scanBarcode()
                  // )
                ],
              ),
              // RoundedIconButton(
              //   icon: Icon(Icons.qr_code, color: Color(0xFFFFFFFF)),
              //   color: Theme.of(context).backgroundColor,
              //   onPressed: _scanQRCode
              // ),
            ],
          ),
          FutureBuilder<List<UserProduct>>(
            future: _apiRoutes.getUserProductsList(),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<UserProduct>> snapshot,
            ) {
              if (!snapshot.hasData) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: const HavkaProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasData) {
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: _apiRoutes.getUserProductsList,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, index) {
                        final UserProduct userProduct = snapshot.data![index];
                        return FridgeItem(userProduct: userProduct);

                        // return ListTile(
                        //   title: Text(
                        //     userProduct.productName!,
                        //     style: TextStyle(
                        //       fontSize: Theme.of(context)
                        //           .textTheme
                        //           .headline3!
                        //           .fontSize,
                        //     ),
                        //   ),
                        //   subtitle: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text(
                        //         userProduct.productBrand!,
                        //         style: TextStyle(
                        //           fontSize: Theme.of(context)
                        //               .textTheme
                        //               .headline4!
                        //               .fontSize,
                        //         ),
                        //       ),
                        //       Text(
                        //         '${userProduct.netWeightLeft!.round()}${userProduct.unit} left',
                        //         style: TextStyle(
                        //           fontSize: Theme.of(context)
                        //               .textTheme
                        //               .headline4!
                        //               .fontSize,
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => UserProductScreen(
                        //           userProduct: userProduct,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   trailing: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       IconButton(
                        //         icon: const Icon(Icons.monitor_weight),
                        //         onPressed: () {
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //               builder: (context) => ScaleScreen(
                        //                 userProduct: userProduct,
                        //               ),
                        //             ),
                        //           ).then((_) => setState(() {}));
                        //         },
                        //       ),
                        //       IconButton(
                        //         icon: const Icon(Icons.delete),
                        //         onPressed: () async {
                        //           await _apiRoutes
                        //               .deleteUserProduct(userProduct);
                        //           setState(() {});
                        //         },
                        //       )
                        //     ],
                        //   ),
                        // );
                      },
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
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
