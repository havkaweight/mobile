import 'package:flutter/material.dart';
import '../../model/user_product.dart';
import '../../ui/screens/scale_screen.dart';
import '../../ui/widgets/rounded_button.dart';
import '../../ui/widgets/screen_header.dart';

class UserProductScreen extends StatefulWidget {
  final UserProduct userProduct;

  const UserProductScreen({super.key, required this.userProduct});

  @override
  _UserProductScreenState createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Hero(
          tag: 'productImage-${widget.userProduct.id}',
          child: Container(
            width: 300,
            height: 300,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xff7c94b6),
              image: widget.userProduct.netWeightLeft != null
                  ? const DecorationImage(
                      image: NetworkImage('https://cdn.havka.one/test.jpg'),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
            ),
          ),
        ),
        Text(
          widget.userProduct.productName!,
          style: const TextStyle(
            color: Colors.black,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
        RoundedButton(
            text: 'Weight',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ScaleScreen(userProduct: widget.userProduct))))
      ])),
    );
  }
}
