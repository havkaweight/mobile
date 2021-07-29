import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/widgets/search_textfield.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
      future: _apiRoutes.getUserProductsList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Column(
            children: <Widget>[
              SearchTextField(
                hintText: 'Search food or barcode',
                width: 0.9,
                controller: searchController,
                icon: const Icon(Icons.search),
              ),
              FutureBuilder<List<UserProduct>>(
                future: _apiRoutes.getUserProductsList(),
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
                  if (!snapshot.hasData) {
                    return Column(
                      children: [
                        ListView(
                          children: snapshot.data.map<Widget>((data) {
                            final String subtitle = 'Protein: ${data.protein
                                .toString()}  Fat: ${data.fat
                                .toString()}  Carbs: ${data.carbs
                                .toString()}  Kcal: ${data.kcal
                                .toString()}';
                            return ListTile(
                              title: Text(data.name),
                              subtitle: Text(subtitle),
                              // onTap: () {
                              //   _addProduct(data);
                              // },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                  return
                  //   const Center(
                  //   child: Text('Error internet connection')
                  // );
                  SizedBox(
                    child: Column(
                      children: [
                        ListTile(
                              title: Text('Havka'),
                              subtitle: Text('Nasha havka'),
                              // onTap: () {
                              //   _addProduct(data);
                              // },
                            ),
                      ],
                    ),
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