import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:http/http.dart' as http;
import 'package:health_tracker/main.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/model/product.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
          body: Column(
            children: <Widget>[
              Row(
                children: const <Widget>[
                  ScreenHeader(
                    text: 'Food'
                  ),
                ],
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
                  return Expanded(
                      child: ListView(
                        children: snapshot.data.map<Widget>((data) {
                          final String subtitle = 'Protein: ${data.protein.toString()}  Fat: ${data.fat.toString()}  Carbs: ${data.carbs.toString()}  Kcal: ${data.kcal.toString()}';
                          return ListTile(
                            title: Text(data.name),
                            subtitle: Text(subtitle),
                            // onTap: () {
                            //   _addProduct(data);
                            // },
                          );
                        }).toList(),
                      )
                  );
                },
              ),
            ])
        );
      }
    );
  }
}