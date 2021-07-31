import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/search_textfield.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'authorization.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final searchController = TextEditingController();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _apiRoutes.getProductsList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Column(
            children: <Widget>[
              SearchTextField(
                hintText: 'Search food or barcode',
                width: 0.9,
                controller: searchController,
                icon: const Icon(Icons.search),
              ),
              FutureBuilder<List<Product>>(
                future: _apiRoutes.getProductsList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  print(snapshot);
                  if (!snapshot.hasData) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: const HavkaProgressIndicator()
                      )
                    );
                  }
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    return SizedBox(
                      height: 500,
                      child: ListView(
                        children: snapshot.data.map<Widget>((product) {
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(product.brand),
                            onTap: () async {
                              await _apiRoutes.addProduct(product);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return const Center(
                    child: Text('Error internet connection')
                  );
                },
              ),
            ]);
      }
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }
}