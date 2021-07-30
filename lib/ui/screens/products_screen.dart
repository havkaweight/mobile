import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';
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
                  const List<Map<String, String>> prod = [
                    {
                      'name': 'Pervoe',
                      'desc': 'Nasha havka',
                      'protein': '3',
                      'fats': '4',
                      'carbs': '50',
                      'kcal': '185'
                    },
                    {
                      'name': 'Vtoroe',
                      'desc': 'Nasha havka',
                      'protein': '40',
                      'fats': '3',
                      'carbs': '10',
                      'kcal': '400'
                    },
                    {
                      'name': 'Kompot',
                      'desc': 'Nasha havka',
                      'protein': '0',
                      'fats': '0',
                      'carbs': '30',
                      'kcal': '50'
                    }
                  ];
                  print(prod);
                  final List<ListTile> tiles = [];
                  for (final Map<String, String> el in prod) {
                    tiles.add(
                      ListTile(
                        title: Text(el['name']),
                        subtitle: Text(el['desc']),
                        onTap: () {
                          tempAddProduct(el);
                          Navigator.pop(context);
                        },
                      )
                    );
                  }
                  return
                  //   const Center(
                  //   child: Text('Error internet connection')
                  // );
                  SizedBox(
                    child: Column(
                      children: [
                        ...tiles
                      ],
                    ),
                  );
                },
              ),
            ]);
      }
    );
  }

  void tempAddProduct(Map<String, String> prod) {
    // final token = await storage.read(key: 'jwt');
    // final http.Response _ = await http.post(
    //     Uri.https(Api.host, '${Api.prefix}/product/add/'),
    //     headers: <String, String>{
    //       'Content-type': 'application/json',
    //       'Accept': 'application/json',
    //       'Authorization': 'Bearer $token'
    //     },
    //     body: jsonEncode(product.toJson())
    // );
    userProductsList.add(prod);
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