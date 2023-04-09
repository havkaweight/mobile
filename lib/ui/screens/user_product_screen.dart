import 'package:flutter/material.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'userProductImage-${widget.userProduct.id}',
              child: Container(
                width: 300,
                height: 300,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: widget.userProduct.product!.img != null
                      ? DecorationImage(
                          image: NetworkImage(widget.userProduct.product!.img!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                ),
              ),
            ),
            Text(
              widget.userProduct.product!.name!,
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
                      ScaleScreen(userProduct: widget.userProduct),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
