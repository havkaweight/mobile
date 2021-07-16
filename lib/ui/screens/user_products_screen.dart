import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:http/http.dart' as http;
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
  final barcodeController = TextEditingController();

  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
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
                    ScreenHeader(
                        text: 'Fridge'
                    ),
                    RoundedButton(
                      text: 'Add food',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsScreen()));
                      },
                    ),
                    // RoundedIconButton(
                    //   icon: Icon(Icons.qr_code, color: Color(0xFFFFFFFF)),
                    //   color: Theme.of(context).backgroundColor,
                    //   onPressed: _scanQRCode
                    // ),
                    // RoundedIconButton(
                    //   faIcon: FaIcon(
                    //     FontAwesomeIcons.barcode,
                    //     color: Color(0xFFFFFFFF),
                    //   ),
                    //   onPressed: () => _apiRoutes.scanBarcode()
                    // )
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
                      style: TextStyle(
                        color: Color(0xFF5BBE78),
                        fontSize: 20,
                      ),
                    );
                  }
                ),
                FutureBuilder<dynamic>(
                  future: _apiRoutes.getUserProductsList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return Center(
                      child: Container(
                          child: HavkaProgressIndicator(),
                          padding: EdgeInsets.symmetric(vertical: 40.0)
                      )
                    );
                    if (snapshot.data.runtimeType == List)
                    return Expanded(
                        child: ListView(
                          scrollDirection: Axis.vertical,
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
                    return Text('No data :-(');
                  },
                ),
              ])
          )
        );
      }
    );
  }
}