import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BarcodeScannerSimpleScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenSimpleState createState() => _BarcodeScannerScreenSimpleState();
}

class _BarcodeScannerScreenSimpleState extends State<BarcodeScannerSimpleScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller.pauseCamera();
  //   } else if (Platform.isIOS) {
  //     controller.resumeCamera();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    return Column(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderColor: HavkaColors.green,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 20,
                  cutOutSize: scanArea)),
        ),
        Expanded(
          flex: 1,
          child: Center(
              child: (result != null)
                  // (result != null)
                  // ? Text(
                  // 'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                  // : const Text('Scan a code'),
                    ? FutureBuilder(
                      future: _apiRoutes.getProductByBarcode(result!.code),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          if (snapshot.hasError) {
                            Navigator.pop(context, result!.code);
                          }
                          return Center(
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: const HavkaProgressIndicator()));
                        }
                        if (snapshot.hasData) {
                          final Product product = snapshot.data as Product;
                          return ListTile(
                              title: Text(product.name!,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .headline3!
                                          .fontSize)),
                              subtitle: Text(product.brand!,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .fontSize)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RoundedButton(
                                    text: 'Add',
                                    onPressed: () async {
                                      await _apiRoutes.addUserProduct(product);
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ));
                        }
                        return Container();
                      })
                  : const Text('Scan a code')),
        )
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
