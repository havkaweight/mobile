import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '/presentation/widgets/nutrition_info.dart';

import '/core/constants/utils.dart';

class BarcodeProductPopup extends StatefulWidget {
  final String barcode;

  const BarcodeProductPopup({
    required this.barcode,
  });

  @override
  _BarcodeProductPopupState createState() => _BarcodeProductPopupState();
}

class _BarcodeProductPopupState extends State<BarcodeProductPopup>
    with TickerProviderStateMixin {
  late AnimationController _barcodeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final AnimationController _addButtonAnimation;
  late final AnimationController _consumeButtonAnimation;

  @override
  void initState() {
    super.initState();
    _barcodeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _addButtonAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _consumeButtonAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_barcodeAnimationController);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(_barcodeAnimationController);
  }

  @override
  void dispose() {
    _barcodeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return SafeArea(
      child: Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 50.0,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
              position: _slideAnimation,
              child: productProvider.isLoading
                  ? Container()
                  : productProvider.barcodeProduct != null
                      ? Builder(builder: (BuildContext context) {
                          _barcodeAnimationController.forward();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    // border: Border.all(color: HavkaColors.bone[100]!),
                                  ),
                                  child: ListTile(
                                    leading: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff7c94b6),
                                          image: productProvider
                                                      .barcodeProduct!.images !=
                                                  null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    productProvider
                                                        .barcodeProduct!
                                                        .images!
                                                        .small!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(50.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      Utils().cutString(
                                          productProvider.barcodeProduct!.name,
                                          30),
                                      style: TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .fontSize,
                                      ),
                                    ),
                                    subtitle: SizedBox(
                                      height: 20,
                                      width: 150,
                                      child: productProvider
                                                  .barcodeProduct!.nutrition ==
                                              null
                                          ? null
                                          : NutritionInfo(product:
                                              productProvider
                                                  .barcodeProduct!,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                                begin: 1.0, end: 0.9)
                                            .animate(_consumeButtonAnimation),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 100),
                                          margin: EdgeInsets.only(right: 5.0),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: GestureDetector(
                                            onTapDown: (_) {
                                              _consumeButtonAnimation.forward();
                                            },
                                            onPanUpdate: (details) {
                                              if (details.delta.dx.abs() > 1 ||
                                                  details.delta.dy.abs() > 1) {
                                                _consumeButtonAnimation
                                                    .reverse();
                                              }
                                            },
                                            onTapUp: (_) {
                                              _consumeButtonAnimation.reverse();
                                              Navigator.pop(context, [
                                                productProvider.barcodeProduct,
                                                "consume"
                                              ]);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 10.0),
                                                    child: Icon(FontAwesomeIcons
                                                        .cookieBite),
                                                  ),
                                                  Text("Consume"),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: ScaleTransition(
                                        scale:
                                            Tween<double>(begin: 1.0, end: 0.9)
                                                .animate(_addButtonAnimation),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 100),
                                          margin: EdgeInsets.only(left: 5.0),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: GestureDetector(
                                            onTapDown: (_) {
                                              _addButtonAnimation.forward();
                                            },
                                            onPanUpdate: (details) {
                                              if (details.delta.dx.abs() > 1 ||
                                                  details.delta.dy.abs() > 1) {
                                                _addButtonAnimation.reverse();
                                              }
                                            },
                                            onTapUp: (_) {
                                              _addButtonAnimation.reverse();
                                              Navigator.pop(context, [
                                                productProvider.barcodeProduct,
                                                "add"
                                              ]);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 10.0),
                                                    child: Icon(Icons.kitchen),
                                                  ),
                                                  Text("Add to Fridge"),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        })
                      : Builder(builder: (BuildContext context) {
                          _barcodeAnimationController.forward();
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                // border: Border.all(color: HavkaColors.bone[100]!),
                              ),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    margin: EdgeInsets.all(5),
                                    child: Icon(
                                      CupertinoIcons.barcode,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  "Add new product",
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .fontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  widget.barcode,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(
                                      context, [widget.barcode, "create"]);
                                },
                              ),
                            ),
                          );
                        })),
        ),
      ),
    );
  }
}
