import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {

  String _data;

  Future _scanBarcode() async {
    await FlutterBarcodeScanner.scanBarcode(
        '#5BBE78',
        'Cancel',
        true,
        ScanMode.BARCODE
    ).then((value) => setState(() => _data = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              RoundedButton(
                  text: 'Scan',
                  onPressed: _scanBarcode
              ),
              Text(
                _data
              ),
            ]
          )
          )
      )
    );
  }

}


