import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/product_measurement_screen.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:http/http.dart' as http;
import 'package:health_tracker/constants/api.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/products_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProductsScreen extends StatefulWidget {
  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {

  String _data = '-';

  @override
  void initState() {
    super.initState();
  }

  Future<List<UserProduct>> getUserProductsList() async {
    final token = await storage.read(key: 'jwt');
    // print('Before: $token');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}/users/me/products'),
        headers: <String, String>{
          'Content-type': 'application/json',
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token'
        }
    );
    // print('After: $token');
    final products = jsonDecode(utf8.decode(response.bodyBytes));
    List<UserProduct> productsList = products.map<UserProduct>((json) {
      return UserProduct.fromJson(json);
    }).toList();
    // print(productsList);
    return productsList;
  }

  Future _scanBarcode() async {
    await FlutterBarcodeScanner.scanBarcode(
        '#5BBE78',
        'Cancel',
        true,
        ScanMode.BARCODE
    ).then((value) => setState(() => _data = value));
  }

  Future _scanQRCode() async {
    await FlutterBarcodeScanner.scanBarcode(
        '#5BBE78',
        'Cancel',
        true,
        ScanMode.QR
    ).then((value) => setState(() => _data = value));
  }

  // Future _addProduct(product) async {
  //   print('Ya tut');
  //   print(jsonEncode(product.toJson()));
  //   final token = await storage.read(key: 'jwt');
  //   final http.Response _ = await http.post(
  //       Uri.https(SERVER_IP, '$API_PREFIX/users/me/products/add/'),
  //       headers: <String, String>{
  //         'Content-type': 'application/json',
  //         'Accept': 'application/json',
  //         // 'Content-Type': 'application/x-www-form-urlencoded',
  //         'Authorization': 'Bearer $token'
  //       },
  //       body: jsonEncode(product.toJson())
  //   );
  // }

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: checkLogIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return WillPopScope(
          onWillPop: () => Navigator.push((context), MaterialPageRoute(builder: (context) => ProfileScreen())),
          child: Scaffold (
            backgroundColor: Theme.of(context).backgroundColor,
            body: Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ScreenHeader(
                        text: 'My products'
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RoundedButton(
                            text: 'Add product',
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsScreen()));
                            },
                          ),
                          RoundedIconButton(
                            icon: Icon(Icons.qr_code, color: Color(0xFFFFFFFF)),
                            color: Theme.of(context).backgroundColor,
                            onPressed: _scanQRCode
                          ),
                          RoundedIconButton(
                            faIcon: FaIcon(
                              FontAwesomeIcons.barcode,
                              color: Color(0xFFFFFFFF),
                            ),
                            onPressed: _scanBarcode
                          )
                        ]
                      ),
                      Text(
                        'Barcode number: $_data',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xFF5BBE78),
                          fontSize: 20,
                        ),
                      ),
                      FutureBuilder<List<UserProduct>>(
                        future: getUserProductsList(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) return Center(
                            child: Container(
                                child: CircularProgressIndicator(),
                                padding: EdgeInsets.symmetric(vertical: 40.0)
                            )
                          );
                          return Expanded(
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                children: snapshot.data.map<Widget>((data) {
                                  return ListTile(
                                    title: Text(data.productName),
                                    subtitle: Text(data.amount.toString()),
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MeasurementScreen(product: data)));
                                    }
                                  );
                                }).toList(),
                              )
                          );
                        },
                      ),
                    ])
                )
            )
          ),
        );
      }
    );
  }
}