import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';

import 'package:health_tracker/ui/screens/barcode_scanner_simple.dart';

class ProductAddingScreen extends StatefulWidget {
  final String? barcode;

  const ProductAddingScreen({this.barcode = ''});
  const ProductAddingScreen.withBarcode(this.barcode);

  @override
  _ProductAddingScreenState createState() => _ProductAddingScreenState();
}

class _ProductAddingScreenState extends State<ProductAddingScreen> {
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final proteinController = TextEditingController();
  final fatsController = TextEditingController();
  final carbsController = TextEditingController();
  final kcalController = TextEditingController();
  final weightController = TextEditingController();
  final unitController = TextEditingController();
  final barcodeController = TextEditingController();
  final barcodeFocusNode = FocusNode();

  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
    barcodeController.text = widget.barcode!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Hero(
                    tag: "product-add",
                    child: FaIcon(
                      FontAwesomeIcons.cartPlus,
                      color: HavkaColors.green,
                      size: 80,
                    ),
                  ),
                ),
                RoundedTextField(
                  hintText: 'Name',
                  controller: nameController,
                ),
                RoundedTextField(
                  hintText: 'Brand',
                  controller: brandController,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedTextField(
                      width: 0.3,
                      hintText: 'Protein',
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                    ),
                    RoundedTextField(
                      width: 0.3,
                      hintText: 'Fats',
                      controller: fatsController,
                      keyboardType: TextInputType.number,
                    ),
                    RoundedTextField(
                      width: 0.3,
                      hintText: 'Carbs',
                      controller: carbsController,
                      keyboardType: TextInputType.number,
                    )
                  ],
                ),
                RoundedTextField(
                  hintText: 'Kcal',
                  controller: kcalController,
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedTextField(
                      width: 0.6,
                      hintText: 'Weight',
                      controller: weightController,
                      keyboardType: TextInputType.number,
                    ),
                    RoundedTextField(
                      width: 0.3,
                      hintText: 'Units',
                      controller: unitController,
                    )
                  ],
                ),
                RoundedTextField(
                  hintText: 'Barcode',
                  controller: barcodeController,
                  keyboardType: TextInputType.number,
                  iconButton: IconButton(
                    icon: const Icon(Icons.qr_code_2),
                    color: HavkaColors.green,
                    onPressed: () {
                      _buildBarcodeScanner().then(
                        (barcode) => setState(() {
                          barcodeController.text = barcode as String;
                        }),
                      );
                    },
                  ),
                ),
                RoundedButton(
                    text: 'Done',
                    onPressed: () {
                      final Product product = Product.fromJson({
                        'name': nameController.text,
                        'brand': brandController.text,
                        'proteins': double.parse(proteinController.text),
                        'fats': double.parse(fatsController.text),
                        'carbs': double.parse(carbsController.text),
                        'kcal': double.parse(kcalController.text),
                        'net_weight': double.parse(weightController.text),
                        'unit': unitController.text,
                        'barcode': barcodeController.text,
                      });
                      _apiRoutes.addProduct(product);
                      Navigator.pop(context);
                    })
              ],
            ),
          ),
        ));
  }

  Future _buildBarcodeScanner() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        context: context,
        builder: (builder) {
          final double mHeight = MediaQuery.of(context).size.height;
          return ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)),
            child: SizedBox(
                height: mHeight * 0.75, child: BarcodeScannerSimpleScreen()),
          );
        }).then((barcode) => barcode);
  }
}
