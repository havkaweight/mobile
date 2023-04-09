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

class _HavkaBarcodeScannerScreenState extends State<HavkaBarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  late AnimationController _barcodeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ValueNotifier<String?> _barcode = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();

    _barcodeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_barcodeAnimationController);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0.0),
      end: Offset.zero,
    ).animate(_barcodeAnimationController);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcode.dispose();
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
            if (widget.isProduct) {
              return BarcodeProductPopup(value);
            }
            return BarcodePopup(value);
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

      if (results.isNotEmpty) {
        final barcode = results.first;
        final value = barcode.rawValue;
        _cameraController.stopImageStream();
        barcodeScanner.close();
        _barcode.value = value;
        // setState(() {
        //   _barcodeValue = value;
        // });
      } else {
        // setState(() {
        //   _barcodeValue = 'No barcode detected';
        // });
      }
    });
  }
}
