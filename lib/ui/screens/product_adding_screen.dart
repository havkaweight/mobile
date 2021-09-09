import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';

class ProductAddingScreen extends StatefulWidget {

  final String barcode;

  const ProductAddingScreen({this.barcode = ''});
  const ProductAddingScreen.withBarcode(this.barcode);

  @override
  _ProductAddingScreenState createState() => _ProductAddingScreenState();
}

class _ProductAddingScreenState extends State<ProductAddingScreen> {

  final nameController = TextEditingController();
  final proteinController = TextEditingController();
  final fatsController = TextEditingController();
  final carbsController = TextEditingController();
  final kcalController = TextEditingController();
  final barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    barcodeController.text = widget.barcode;
  }

  Product _addProduct() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundedTextField(hintText: 'Name', controller: nameController),
            RoundedTextField(hintText: 'Protein', controller: proteinController, keyboardType: TextInputType.number),
            RoundedTextField(hintText: 'Fats', controller: fatsController, keyboardType: TextInputType.number),
            RoundedTextField(hintText: 'Carbs', controller: carbsController, keyboardType: TextInputType.number),
            RoundedTextField(hintText: 'Kcal', controller: kcalController, keyboardType: TextInputType.number),
            RoundedTextField(hintText: 'Barcode', controller: barcodeController, keyboardType: TextInputType.number, icon: const Icon(Icons.qr_code, color: HavkaColors.green,)),
            RoundedButton(text: 'Done', onPressed: () {
              _addProduct();
              Navigator.pop(context);
            })
          ],
        ),
      )
    );
  }
}