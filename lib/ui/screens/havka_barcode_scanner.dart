import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:health_tracker/ui/screens/barcode_popup.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:health_tracker/ui/screens/barcode_product_popup.dart';
import 'package:health_tracker/ui/widgets/detection_box.dart';

class HavkaBarcodeScannerScreen extends StatefulWidget {
  final bool isProduct;

  const HavkaBarcodeScannerScreen({required this.isProduct});

  @override
  _HavkaBarcodeScannerScreenState createState() =>
      _HavkaBarcodeScannerScreenState();
}

class _HavkaBarcodeScannerScreenState extends State<HavkaBarcodeScannerScreen> {
  late CameraController _cameraController;
  final ValueNotifier<String?> _barcode = ValueNotifier<String?>(null);
  late final Timer scanningTimer;

  @override
  void initState() {
    super.initState();
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
        future: _initCameraController(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return _showCameraPreview();
        },
      ),
    );
  }

  Widget _showCameraPreview() {
    if (!_cameraController.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: CameraPreview(
            _cameraController,
          ),
        ),
        CustomPaint(
          painter: DetectionBox(),
          child: Container(),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: _barcode,
          builder: (BuildContext context, String? value, _) {
            if (value != null) {
              if (widget.isProduct) {
                return BarcodeProductPopup(value);
              }
              return BarcodePopup(value);
            }
            return Container();
          },
        ),
      ],
    );
  }

  Future<void> _initCameraController() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController.initialize();
    await startBarcodeScanning();
  }

  Future<void> startBarcodeScanning() async {
    scanningTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      _cameraController.startImageStream((cameraImage) async {
        final planeData = cameraImage.planes.map(
          (Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          },
        ).toList();
        final inputImage = InputImage.fromBytes(
          bytes: Uint8List.fromList(
            cameraImage.planes.fold(
              <int>[],
              (List<int> previousValue, element) =>
                  previousValue..addAll(element.bytes),
            ),
          ),
          inputImageData: InputImageData(
            size: Size(
              cameraImage.width.toDouble(),
              cameraImage.height.toDouble(),
            ),
            imageRotation: InputImageRotation.rotation0deg,
            inputImageFormat: InputImageFormat.bgra8888,
            planeData: planeData,
          ),
        );
        final List<BarcodeFormat> formats = [BarcodeFormat.all];
        final barcodeScanner = BarcodeScanner(formats: formats);
        final results = await barcodeScanner.processImage(inputImage);
        if (results.isEmpty) return;
        final barcode = results.first;
        final value = barcode.rawValue;
        _cameraController.stopImageStream();
        barcodeScanner.close();
        _barcode.value = value;
      });
    });
  }
}
