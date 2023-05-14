import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/search_textfield.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final searchController = TextEditingController();

  // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // Barcode? result;
  // QRViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final headerBlockHeight = MediaQuery.of(context).size.height * 0.85 * 0.08;
    final listBlockHeight =
        MediaQuery.of(context).size.height * 0.82 - headerBlockHeight;
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 0) {
          Navigator.pop(context);
        }
      },
      child: Column(
        children: [
          SizedBox(
            height: headerBlockHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SearchTextField(
                  hintText: 'Search food',
                  width: 0.8,
                  controller: searchController,
                  icon: const Icon(Icons.search),
                ),
                Hero(
                  tag: "product-add",
                  child: IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.plus,
                      color: HavkaColors.green,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductAddingScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (searchController.text.isEmpty)
            FutureBuilder<List<Product>>(
              future: _apiRoutes.getProductsList(),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Product>> snapshot,
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
                  return SizedBox(
                    height: listBlockHeight,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, index) {
                        final Product product = snapshot.data![index];
                        return ListTile(
                          tileColor: Colors.transparent,
                          leading: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image: product.img != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        product.img!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50.0)),
                              border: Border.all(
                                color: HavkaColors.cream,
                                width: 3,
                              ),
                            ),
                          ),
                          title: Text(
                            product.name!,
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .fontSize,
                            ),
                          ),
                          subtitle: Text(
                            product.brand ?? 'BRAND Placeholder',
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .fontSize,
                            ),
                          ),
                          onTap: () async {
                            await _apiRoutes
                                .addUserProduct(product)
                                .then((value) => Navigator.pop(context));
                          },
                        );
                      },
                    ),
                  );
                }
                return const Center(child: Text('Error internet connection'));
              },
            )
          else
            FutureBuilder<List<Product>>(
              future: _apiRoutes
                  .getProductsBySearchingRequest(searchController.text),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Product>> snapshot,
              ) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: HavkaProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  const Center(child: Text('Error internet connection'));
                }
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, index) {
                      final Product product = snapshot.data![index];
                      return ListTile(
                        tileColor: Colors.transparent,
                        leading: Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: product.img != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      product.img!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                            border: Border.all(
                              color: HavkaColors.cream,
                              width: 3,
                            ),
                          ),
                        ),
                        title: Text(
                          product.name ?? 'NAME Placeholder',
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .fontSize,
                          ),
                        ),
                        subtitle: Text(
                          product.brand ?? 'BRAND Placeholder',
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .fontSize,
                          ),
                        ),
                        onTap: () async {
                          await _apiRoutes
                              .addUserProduct(product)
                              .then((value) => Navigator.pop(context));
                        },
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
