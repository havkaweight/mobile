import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/products_screen.dart';
import 'package:health_tracker/ui/screens/user_product_screen.dart';
import 'package:health_tracker/ui/widgets/circular_progress_bar.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HavkaColors.bone[100]!),
        ),
        child: ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: <Widget>[
                Hero(
                  tag: 'productImage-${userProduct.id}',
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xff7c94b6),
                      image: userProduct.netWeightLeft != null
                          ? const DecorationImage(
                              image: NetworkImage(
                                  'https://cdn.havka.one/test.jpg'),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50.0)),
                    ),
                  ),
                ),
                SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressBar(value: Random().nextDouble()))
              ],
            ),
          ),
          title: Text(
            userProduct.productName ?? 'NAME Placeholder',
            style: TextStyle(
              color: Colors.black,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
              fontSize: Theme.of(context).textTheme.headline3!.fontSize,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userProduct.productBrand ?? 'BRAND Placeholder',
                style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                  fontSize: Theme.of(context).textTheme.headline4!.fontSize,
                ),
              ),
              Text(
                '100 000 g',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline4!.fontSize,
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
      ),
    );
  }
}

class EmptyFridgeItem extends StatelessWidget {
  const EmptyFridgeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HavkaColors.bone[100]!),
        ),
        child: ListTile(
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
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  ),
                ),
                const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressBar(value: -1))
              ],
            ),
          ),
          title: const SizedBox(
            width: 30,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.green,
              ),
            ),
          ),
          subtitle: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.green,
            ),
            width: 20,
            height: 9,
          ),
        ),
      ),
    );
  }
}
