import 'package:flutter/material.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

class UserProductScreen extends StatefulWidget {
  final UserProduct userProduct;

  const UserProductScreen({
    Key? key,
    required this.userProduct
  }) : super(key: key);

  @override
  _UserProductScreenState createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScreenSubHeader(text: widget.userProduct.productName!),
            ScreenSubHeader(text: widget.userProduct.productBrand!),
            RoundedButton(
              text: 'Weigh',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleScreen(userProduct: widget.userProduct)))
            )
          ]
        )
      ),
    );
  }
}