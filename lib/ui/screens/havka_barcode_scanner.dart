import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/product.dart';

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
  late String? _barcodeValue;
  late AnimationController _barcodeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
    _barcodeValue = null;

    _barcodeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(_barcodeAnimationController);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0.0),
      end: Offset.zero,
    ).animate(_barcodeAnimationController);
  }

  @override
  void dispose() {
    _cameraController.dispose();
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

  Widget barcode() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(_barcodeValue);
                  },
                  child: Text(
                    _barcodeValue!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget productByBarcode() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: FutureBuilder(
              future: _apiRoutes.getProductByBarcode(_barcodeValue),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print(snapshot.data);
                final Product product = snapshot.data as Product;
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: HavkaColors.cream,
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
                                        'https://cdn.havka.one/test.jpg'),
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
                              Theme.of(context).textTheme.headline3!.fontSize,
                        ),
                      ),
                      subtitle: Text(
                        product.barcode ?? 'BARCODE Placeholder',
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal,
                          fontSize:
                              Theme.of(context).textTheme.headline4!.fontSize,
                        ),
                      ),
                      onTap: () async {
                        await _apiRoutes.addUserProduct(product);
                        Navigator.of(context).pop();
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
        if (_barcodeValue != null)
          if (widget.isProduct) productByBarcode() else barcode()
        else
          Container(),
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

      final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
      final results = await barcodeScanner.processImage(inputImage);

      if (results.isNotEmpty) {
        final barcode = results.first;
        final value = barcode.rawValue;
        _cameraController.stopImageStream();
        barcodeScanner.close();
        _barcodeAnimationController.forward();
        setState(() {
          _barcodeValue = value;
        });
      } else {
        // setState(() {
        //   _barcodeValue = 'No barcode detected';
        // });
      }
    });
  }
}
