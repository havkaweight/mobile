import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';

class BarcodeProductPopup extends StatefulWidget {
  final String? barcode;

  const BarcodeProductPopup(this.barcode);

  @override
  _BarcodeProductPopupState createState() => _BarcodeProductPopupState();
}

class _BarcodeProductPopupState extends State<BarcodeProductPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _barcodeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
    _barcodeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: FutureBuilder(
              future: _apiRoutes.getProductByBarcode(widget.barcode),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                }
                final Product product = snapshot.data as Product;
                _barcodeAnimationController.forward();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: HavkaColors.bone[100]!),
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
                            image: product.img != null
                                ? const DecorationImage(
                                    image: NetworkImage(
                                      'https://cdn.havka.one/test.jpg',
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
                        product.name ?? 'NAME Placeholder',
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal,
                          fontSize:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                        ),
                      ),
                      subtitle: Text(
                        product.barcode ?? 'BARCODE Placeholder',
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal,
                          fontSize:
                              Theme.of(context).textTheme.labelMedium!.fontSize,
                        ),
                      ),
                      onTap: () async {
                        await _apiRoutes
                            .addUserProduct(product)
                            .then((value) => Navigator.of(context).pop());
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
