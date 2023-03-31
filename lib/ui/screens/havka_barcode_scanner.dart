import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../widgets/detection_box.dart';
import 'barcode_scanner_service.dart';

class HavkaBarcodeScannerScreen extends StatefulWidget {
  @override
  _HavkaBarcodeScannerScreenState createState() =>
      _HavkaBarcodeScannerScreenState();
}

class _HavkaBarcodeScannerScreenState extends State<HavkaBarcodeScannerScreen> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    if (_cameraController != null && !_cameraController!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: CameraPreview(_cameraController!),
        ),
        CustomPaint(
          painter: DetectionBox(),
          child: Container(),
        ),
      ],
    );
  }

  Future _initCameraController() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium,
        enableAudio: false);
    await _cameraController!.initialize();
  }
}
