import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/user_product_screen.dart';

import '../screens/scale_screen.dart';

class FridgeItem extends StatelessWidget {
  final UserProduct userProduct;

  const FridgeItem({
    Key? key,
    required this.userProduct,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: HavkaColors.green, width: 1),
        borderRadius: BorderRadius.circular(5),
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
    );
  }
}
