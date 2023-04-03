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
  const ProductAddingScreen.withBarcode({required this.barcode});

  @override
  _ProductAddingScreenState createState() => _ProductAddingScreenState();
}

class _ProductAddingScreenState extends State<ProductAddingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController kcalController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  final FocusNode brandFocusNode = FocusNode();
  final FocusNode proteinFocusNode = FocusNode();
  final FocusNode fatsFocusNode = FocusNode();
  final FocusNode carbsFocusNode = FocusNode();
  final FocusNode kcalFocusNode = FocusNode();
  final FocusNode weightFocusNode = FocusNode();
  final FocusNode unitFocusNode = FocusNode();
  final FocusNode barcodeFocusNode = FocusNode();

  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
    barcodeController.text = widget.barcode!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).backgroundColor,
          body: SingleChildScrollView(
            reverse: true,
            child: SafeArea(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
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
                        onSubmitted: (_) => brandFocusNode.requestFocus(),
                      ),
                      RoundedTextField(
                        hintText: 'Brand',
                        controller: brandController,
                        focusNode: brandFocusNode,
                        onSubmitted: (_) => proteinFocusNode.requestFocus(),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      RoundedTextField(
                        hintText: 'Protein',
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        focusNode: proteinFocusNode,
                        onSubmitted: (_) => fatsFocusNode.requestFocus(),
                      ),
                      RoundedTextField(
                        hintText: 'Fats',
                        controller: fatsController,
                        keyboardType: TextInputType.number,
                        focusNode: fatsFocusNode,
                        onSubmitted: (_) => carbsFocusNode.requestFocus(),
                      ),
                      RoundedTextField(
                        hintText: 'Carbs',
                        controller: carbsController,
                        keyboardType: TextInputType.number,
                        focusNode: carbsFocusNode,
                        onSubmitted: (_) => kcalFocusNode.requestFocus(),
                      ),
                      RoundedTextField(
                        hintText: 'Kcal',
                        controller: kcalController,
                        keyboardType: TextInputType.number,
                        focusNode: kcalFocusNode,
                        onSubmitted: (_) => barcodeFocusNode.requestFocus(),
                      ),
                      RoundedTextField(
                        width: 100,
                        hintText: 'Barcode',
                        controller: barcodeController,
                        keyboardType: TextInputType.number,
                        focusNode: barcodeFocusNode,
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
                          _addProduct();
                          Navigator.pop(context);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void _addProduct() {
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
