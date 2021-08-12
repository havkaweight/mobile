import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/model/user_product_weighting.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/search_textfield.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'authorization.dart';

class WeightingsScreen extends StatefulWidget {
  @override
  _WeightingsScreenState createState() => _WeightingsScreenState();
}

class _WeightingsScreenState extends State<WeightingsScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      FutureBuilder<List<UserProductWeighting>>(
        future: _apiRoutes.getWeightingsHistory(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: const HavkaProgressIndicator()));
          }
          if (snapshot.hasData) {
            final double mHeight = MediaQuery.of(context).size.height;
            return SizedBox(
              height: mHeight * 0.82,
              child: ListView(
                children: snapshot.data.map<Widget>((weighting) {
                  print(weighting);
                  return ListTile(
                    title: Text(weighting.userProductWeight.toString()),
                    subtitle: Text(weighting.userProductName),
                    onTap: () async {
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            );
          }
          return const Center(child: Text('Error internet connection'));
        },
      )
    ]);
  }
}
