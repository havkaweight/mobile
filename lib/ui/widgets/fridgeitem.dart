import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/user_product_screen.dart';
import 'package:health_tracker/ui/widgets/circle_progress_bar.dart';

import '../screens/scale_screen.dart';

class FridgeItem extends StatelessWidget {
  final UserProduct userProduct;

  const FridgeItem({
    super.key,
    required this.userProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HavkaColors.green, width: 1),
          borderRadius: BorderRadius.circular(50),
        ),
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xff7c94b6),
                    image: DecorationImage(
                      image: NetworkImage('https://cdn.havka.one/test.jpg') ,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  ),
                ),
                SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressBar(value: Random().nextDouble())
                )
              ],
          ),
        ),
        title: Text(
          userProduct.productName!,
          style: TextStyle(
            fontSize: Theme.of(context)
                .textTheme
                .headline3!
                .fontSize,
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              userProduct.productBrand!,
              style: TextStyle(
                fontSize: Theme.of(context)
                    .textTheme
                    .headline4!
                    .fontSize,
              ),
            ),
            Text(
              '${userProduct.netWeightLeft!.round()}${userProduct.unit} left',
              style: TextStyle(
                fontSize: Theme.of(context)
                    .textTheme
                    .headline4!
                    .fontSize,
              ),
            )
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProductScreen(
                userProduct: userProduct,
              ),
            ),
          );
        },
        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.monitor_weight),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => ScaleScreen(
        //               userProduct: userProduct,
        //             ),
        //           ),
        //         ).then((_) => setState(() {}));
        //       },
        //     ),
        //     IconButton(
        //       icon: const Icon(Icons.delete),
        //       onPressed: () async {
        //         await _apiRoutes
        //             .deleteUserProduct(userProduct);
        //         setState(() {});
        //       },
        //     )
        //   ],
        // ),
      ),
    );
  }
}
