import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_tracker/user_products_screen.dart';
import 'package:health_tracker/widgets/screen_header.dart';
import 'package:health_tracker/sign_in_screen.dart';
import 'package:http/http.dart' as http;
import 'constants/api.dart';
import 'main.dart';
import 'authorization.dart';
import 'model/product.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<List<Product>> getUserProductsList() async {
    final token = await storage.read(key: 'jwt');
    // print('Before: $token');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}/product'),
        headers: <String, String>{
          'Content-type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token'
        }
    );
    // print('After: $token');
    final products = jsonDecode(utf8.decode(response.bodyBytes));
    List<Product> productsList = products.map<Product>((json) {
      return Product.fromJson(json);
    }).toList();
    return productsList;
  }

  Future _addProduct(product) async {
    print('Ya tut');
    print(jsonEncode(product.toJson()));
    final token = await storage.read(key: 'jwt');
    final http.Response _ = await http.post(
        Uri.https(Api.host, '${Api.prefix}/product/add/'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(product.toJson())
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserProductsScreen()));
  }

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: checkLogIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return !isLoggedIn
        ? SignInScreen()
        : Scaffold (
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScreenHeader(
                text: 'Products'
              ),
              FutureBuilder<List<Product>>(
                future: getUserProductsList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  print(snapshot);
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
                          final String subtitle = 'Protein: ${data.protein.toString()}  Fat: ${data.fat.toString()}  Carbs: ${data.carbs.toString()}  Kcal: ${data.kcal.toString()}';
                          return ListTile(
                            title: Text(data.name),
                            subtitle: Text(subtitle),
                            onTap: () {
                              _addProduct(data);
                            },
                          );
                        }).toList(),
                      )
                  );
                },
              ),
            ])
        )
      )
    );
      }
    );
  }
}