import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
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
  Barcode? result;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SearchTextField(
            hintText: 'Search food',
            width: 0.8,
            controller: searchController,
            icon: const Icon(Icons.search),
          ),
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductAddingScreen()));
          }, icon: const Icon(Icons.add, color: HavkaColors.green))
        ],
      ),
      if (searchController.text.isEmpty)
        FutureBuilder<List<Product>>(
          future: _apiRoutes.getProductsList(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            print(snapshot);
            if (!snapshot.hasData) {
              return Center(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: const HavkaProgressIndicator()));
            }
            if (snapshot.hasData) {
              final double mHeight = MediaQuery.of(context).size.height;
              return SizedBox(
                height: mHeight * 0.7,
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, index) {
                      final Product product = snapshot.data![index];
                      return ListTile(
                        title: Text(product.name!,
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .fontSize)),
                        subtitle: Text(product.brand!,
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .fontSize)),
                        onTap: () async {
                          await _apiRoutes.addUserProduct(product);
                          Navigator.pop(context);
                        },
                      );
                    }),
              );
            }
            return const Center(child: Text('Error internet connection'));
          },
        )
      else
        FutureBuilder<List<Product>>(
          future:
              _apiRoutes.getProductsBySearchingRequest(searchController.text),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            print(snapshot);
            if (!snapshot.hasData) {
              return Center(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: const HavkaProgressIndicator()));
            }
            if (snapshot.hasData) {
              final double mHeight = MediaQuery.of(context).size.height;
              return SizedBox(
                height: mHeight * 0.73,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, index) {
                    final Product product = snapshot.data![index];
                    return ListTile(
                      title: Text(product.name!),
                      subtitle: Text(product.brand!),
                      onTap: () async {
                        await _apiRoutes.addUserProduct(product);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            }
            return const Center(child: Text('Error internet connection'));
          },
        ),
    ]);
  }
}
