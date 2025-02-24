import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BarcodePopup extends StatefulWidget {
  final String? barcode;

  const BarcodePopup(this.barcode);

  @override
  _BarcodePopupState createState() => _BarcodePopupState();
}

class _BarcodePopupState extends State<BarcodePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _barcodeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    if (widget.barcode != null) {
      setState(() {
        _barcodeAnimationController.forward();
      });
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
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
                    widget.barcode!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, widget.barcode);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
