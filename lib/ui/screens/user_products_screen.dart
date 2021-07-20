import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/screens/products_screen.dart';

import 'barcode_scanner.dart';

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
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _apiRoutes.getUserProductsList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Scaffold (
          backgroundColor: Theme.of(context).backgroundColor,
          body: Container(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const ScreenHeader(
                        text: 'Fridge'
                    ),
                    Row(
                      children: [
                        RoundedButton(
                          text: 'Add food',
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsScreen()));
                            // _buildProductsList();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.qr_code_2, color: HavkaColors.green),
                            onPressed: () {
                              _buildBarcodeScanner();
                            }
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
                              ]
                ),
                RoundedTextField(
                  labelText: 'Barcode number',
                  hintText: '4604921001960',
                  keyboardType: TextInputType.number,
                  controller: barcodeController,
                ),
                FutureBuilder(
                  future: _apiRoutes.getProductByBarcode(barcodeController.text),
                  builder: (context, snapshot) {
                    return Text(
                      'Havka: ${snapshot.data}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: HavkaColors.green,
                        fontSize: 20,
                      ),
                    );
                  }
                ),
                FutureBuilder<dynamic>(
                  future: _apiRoutes.getUserProductsList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: const HavkaProgressIndicator()
                      )
                    );
                    }
                    if (snapshot.data.runtimeType == List) {
                      return Expanded(
                        child: ListView(
                          children: snapshot.data.map<Widget>((data) {
                            return ListTile(
                              title: Text(data.productName),
                              subtitle: Text(data.amount.toString()),
                              // onTap: () {
                              //   Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementScreen(product: data)));
                              // }
                            );
                          }).toList(),
                        )
                    );
                    }
                    return const Text('No data :-(');
                  },
                ),
              ])
          )
        );
      }
    );
  }

  Future<dynamic> _buildBarcodeScanner() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
        // backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            )
        ),
        context: context,
        builder: (builder) {
          final double mWidth = MediaQuery.of(context).size.width;
          final double mHeight = MediaQuery.of(context).size.height;
          return ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            ),
            child: Container(
              width: mWidth,
              height: mHeight * 0.75,
              child: BarcodeScannerScreen()
            ),
          );
        }
    );
  }

  Future<Widget> _buildProductsList() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))
        ),
        context: context, builder: (builder) {
      double mWidth = MediaQuery.of(context).size.width;
      double mHeight = MediaQuery.of(context).size.height;
      return Container(
        // padding: EdgeInsets.symmetric(vertical: 10.0),
          width: mWidth,
          height: mHeight * 0.75,
          child: Column(
              children: [
                Holder(),
                Container(
                  child: Center(
                      child: ProductsScreen()
                  ),
                )
              ]
          )
      );
    }
    );
  }

}