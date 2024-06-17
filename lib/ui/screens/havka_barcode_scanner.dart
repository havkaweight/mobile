import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:havka/ui/screens/barcode_popup.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:havka/ui/screens/barcode_product_popup.dart';
import 'package:havka/ui/widgets/detection_box.dart';

class HavkaBarcodeScannerScreen extends StatefulWidget {
  final CameraDescription camera;
  final bool isProduct;
  const HavkaBarcodeScannerScreen({
    required this.camera,
    required this.isProduct,
  });

  @override
  _HavkaBarcodeScannerScreenState createState() =>
      _HavkaBarcodeScannerScreenState();
}

class _HavkaBarcodeScannerScreenState extends State<HavkaBarcodeScannerScreen> {

  late CameraController _cameraController;
  final ValueNotifier<String?> _barcode = ValueNotifier<String?>(null);
  late final Timer scanningTimer;
  late Future _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    _initializeControllerFuture = _cameraController.initialize();
    startBarcodeScanning();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcode.dispose();
    scanningTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator();
          }
          return _showCameraPreview();
        },
      ),
    );
  }

  Widget _showCameraPreview() {
    if (!_cameraController.value.isInitialized) {
      return CircularProgressIndicator();
    }

    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: CameraPreview(
            _cameraController,
          ),
        ),
        Container(
          child: DetectionBox(
            width: 120,
            height: 80,
            lineRadius: 5,
            lineWidth: 30,
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: _barcode,
          builder: (BuildContext context, String? value, _) {
            if (value == null) {
              return Container();
            }
            if (widget.isProduct) {
              return BarcodeProductPopup(barcode: value);
            }
            return BarcodePopup(value);
          },
        ),
      ],
    );
  }

  Future<void> startBarcodeScanning() async {
    scanningTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      _cameraController.startImageStream((cameraImage) async {
        if (cameraImage.planes.isEmpty) {
          return;
        }
        final plane = cameraImage.planes.first;
        final imageMetadata = InputImageMetadata(
          bytesPerRow: plane.bytesPerRow,
          size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
        );

        final inputImage = InputImage.fromBytes(
          bytes: plane.bytes,
          metadata: imageMetadata,
        );

        final List<BarcodeFormat> formats = [
          BarcodeFormat.ean13,
          BarcodeFormat.upca,
          BarcodeFormat.ean8,
          BarcodeFormat.upce,
        ];
        final barcodeScanner = BarcodeScanner(formats: formats);
        final results = await barcodeScanner.processImage(inputImage);
        if (results.isNotEmpty) {
          final barcode = results.first;
          final value = barcode.rawValue;
          _barcode.value = value;
        }
        _cameraController.stopImageStream();
        barcodeScanner.close();
      });
    });
  }
}
