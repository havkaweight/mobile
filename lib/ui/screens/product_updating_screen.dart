import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/product_energy.dart';
import 'package:health_tracker/model/product_measure.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/havka_barcode_scanner.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';

class ProductUpdatingScreen extends StatefulWidget {
  final Product product;

  const ProductUpdatingScreen({required this.product});

  @override
  _ProductUpdatingScreenState createState() => _ProductUpdatingScreenState();
}

class _ProductUpdatingScreenState extends State<ProductUpdatingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController energyValueController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final List<String> energyUnits = ['kcal', 'kJ'];
  late String energyUnit;
  String prevText = '';

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode brandFocusNode = FocusNode();
  final FocusNode proteinFocusNode = FocusNode();
  final FocusNode fatsFocusNode = FocusNode();
  final FocusNode carbsFocusNode = FocusNode();
  final FocusNode energyValueFocusNode = FocusNode();
  final FocusNode energyUnitFocusNode = FocusNode();
  final FocusNode weightFocusNode = FocusNode();
  final FocusNode unitFocusNode = FocusNode();
  final FocusNode barcodeFocusNode = FocusNode();

  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();

    barcodeController.text = widget.product.barcode ?? '';
    nameController.text = widget.product.name ?? '';
    brandController.text = widget.product.brand ?? '';
    proteinController.text = widget.product.nutrition?.protein.toString() ?? '';
    fatsController.text = widget.product.nutrition?.fat.toString() ?? '';
    carbsController.text = widget.product.nutrition?.carbs.toString() ?? '';
    energyValueController.text =
        widget.product.nutrition?.energy?.first.value.toString() ?? '';

    energyUnit = energyUnits.first;
    proteinController.addListener(_changeNutritionValues);
    fatsController.addListener(_changeNutritionValues);
    carbsController.addListener(_changeNutritionValues);
    energyValueController.addListener(_changeNutritionValues);
  }

  void _changeNutritionValues() {
    if (proteinController.text.isNotEmpty) {
      if (prevText != proteinController.text) {
        String newText = proteinController.text;
        if (newText.contains(',')) {
          newText = newText.replaceAll(',', '.');
          proteinController.text = proteinController.text.replaceAll(',', '.');
          proteinController.selection = TextSelection.fromPosition(
            TextPosition(offset: proteinController.text.length),
          );
        }
        prevText = newText;
      }
    } else {
      proteinController.text = '';
    }
    if (fatsController.text.isNotEmpty) {
      if (prevText != fatsController.text) {
        String newText = fatsController.text;
        if (newText.contains(',')) {
          newText = newText.replaceAll(',', '.');
          fatsController.text = fatsController.text.replaceAll(',', '.');
          fatsController.selection = TextSelection.fromPosition(
            TextPosition(offset: fatsController.text.length),
          );
        }
        prevText = newText;
      }
    } else {
      fatsController.text = '';
    }
    if (carbsController.text.isNotEmpty) {
      if (prevText != carbsController.text) {
        String newText = carbsController.text;
        if (newText.contains(',')) {
          newText = newText.replaceAll(',', '.');
          carbsController.text = carbsController.text.replaceAll(',', '.');
          carbsController.selection = TextSelection.fromPosition(
            TextPosition(offset: carbsController.text.length),
          );
        }
        prevText = newText;
      }
    } else {
      carbsController.text = '';
    }
    if (energyValueController.text.isNotEmpty) {
      if (prevText != energyValueController.text) {
        String newText = energyValueController.text;
        if (newText.contains(',')) {
          newText = newText.replaceAll(',', '.');
          energyValueController.text =
              energyValueController.text.replaceAll(',', '.');
          energyValueController.selection = TextSelection.fromPosition(
            TextPosition(offset: energyValueController.text.length),
          );
        }
        prevText = newText;
      }
    } else {
      energyValueController.text = '';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
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
                          FontAwesomeIcons.squarePen,
                          color: HavkaColors.green,
                          size: 80,
                        ),
                      ),
                    ),
                    RoundedTextField(
                      width: 100,
                      hintText: 'Barcode',
                      controller: barcodeController,
                      keyboardType: TextInputType.number,
                      focusNode: barcodeFocusNode,
                      onSubmitted: (_) => nameFocusNode.requestFocus(),
                      iconButton: IconButton(
                        icon: const FaIcon(FontAwesomeIcons.barcode),
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
                    SizedBox(
                      height: 40,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: const [
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 100,
                            child: ColoredBox(
                              color: HavkaColors.cream,
                              child: Center(
                                child: Text(
                                  "Basic Info",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    RoundedTextField(
                      hintText: 'Name',
                      controller: nameController,
                      focusNode: nameFocusNode,
                      onSubmitted: (_) => brandFocusNode.requestFocus(),
                    ),
                    RoundedTextField(
                      hintText: 'Brand',
                      controller: brandController,
                      focusNode: brandFocusNode,
                      onSubmitted: (_) => proteinFocusNode.requestFocus(),
                    ),
                    SizedBox(
                      height: 40,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: const [
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 150,
                            child: ColoredBox(
                              color: HavkaColors.cream,
                              child: Center(
                                child: Text(
                                  "Nutrition per 100g",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    RoundedTextField(
                      hintText: 'Protein',
                      controller: proteinController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      focusNode: proteinFocusNode,
                      onSubmitted: (_) => fatsFocusNode.requestFocus(),
                    ),
                    RoundedTextField(
                      hintText: 'Fats',
                      controller: fatsController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      focusNode: fatsFocusNode,
                      onSubmitted: (_) => carbsFocusNode.requestFocus(),
                    ),
                    RoundedTextField(
                      hintText: 'Carbs',
                      controller: carbsController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      focusNode: carbsFocusNode,
                      onSubmitted: (_) => energyValueFocusNode.requestFocus(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200,
                          child: RoundedTextField(
                            hintText: 'Energy',
                            controller: energyValueController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            focusNode: energyValueFocusNode,
                            // onSubmitted: (_) => Focus.of(context).unfocus(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: HavkaColors.bone[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton(
                              underline: const SizedBox(),
                              borderRadius: BorderRadius.circular(10),
                              value: energyUnit,
                              items: [
                                for (String eUnit in energyUnits)
                                  DropdownMenuItem(
                                    value: eUnit,
                                    child: Text(eUnit),
                                  )
                              ],
                              onChanged: _energyUnitCallback,
                            ),
                          ),
                        ),
                      ],
                    ),
                    RoundedButton(
                      text: 'Done',
                      onPressed: () {
                        _updateProduct();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _energyUnitCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        energyUnit = selectedValue;
      });
    }
  }

  void _updateProduct() {
    final Product product = Product(
      id: widget.product.id,
      name: nameController.text,
      brand: brandController.text,
      nutrition: ProductNutrition(
        // productMeasure: ProductMeasure(unit: 'g', value: 100),
        protein: proteinController.text.isNotEmpty
            ? double.parse(proteinController.text)
            : null,
        fat: fatsController.text.isNotEmpty
            ? double.parse(fatsController.text)
            : null,
        carbs: carbsController.text.isNotEmpty
            ? double.parse(carbsController.text)
            : null,
        energy: energyValueController.text.isNotEmpty
            ? [
                ProductEnergy(
                  unit: energyUnit,
                  value: double.parse(energyValueController.text),
                )
              ]
            : null,
      ),
      barcode: barcodeController.text,
    );
    _apiRoutes.updateProduct(product);
  }

  Future _buildBarcodeScanner() {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      context: context,
      builder: (builder) {
        final double mHeight = MediaQuery.of(context).size.height;
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: SizedBox(
            height: mHeight * 0.75,
            child: const HavkaBarcodeScannerScreen(
              isProduct: false,
            ),
          ),
        );
      },
    ).then((barcode) => barcode);
  }
}
