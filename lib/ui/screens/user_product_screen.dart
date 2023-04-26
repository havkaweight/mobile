import 'package:flutter/material.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/routes/sharp_page_route.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/widgets/nutrition_line.dart';
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Hero(
                    tag: 'userProductImage-${widget.userProduct.id}',
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 300,
                        height: 300,
                        margin: const EdgeInsets.only(bottom: 30.0),
                        decoration: BoxDecoration(
                          color: const Color(0xff7c94b6),
                          image: widget.userProduct.product!.img != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                      widget.userProduct.product!.img!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50.0)),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.userProduct.product!.name!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: buildNutritionLine(
                        widget.userProduct.product!.nutrition),
                  ),
                ],
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
      ),
    );
  }
}
