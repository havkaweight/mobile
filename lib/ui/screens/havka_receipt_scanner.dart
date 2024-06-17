import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:havka/routes/transparent_page_route.dart';
import 'package:havka/ui/screens/receipt_analysing_screen.dart';
import 'package:havka/ui/widgets/detection_box.dart';

import '../../constants/colors.dart';

class HavkaReceiptScannerScreen extends StatefulWidget {
  final CameraDescription camera;
  const HavkaReceiptScannerScreen({
    required this.camera,
  });

  @override
  _HavkaReceiptScannerScreenState createState() =>
      _HavkaReceiptScannerScreenState();
}

class _HavkaReceiptScannerScreenState extends State<HavkaReceiptScannerScreen> {

  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

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
        Hero(
          tag: "receiptCameraImage",
          child: SizedBox(
            height: double.infinity,
            child: CameraPreview(_cameraController),
          ),
        ),
        DetectionBox(
          width: 140,
          height: 180,
          lineRadius: 5,
          lineWidth: 30,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 80.0),
          alignment: AlignmentDirectional.bottomCenter,
          child: TextButton(
            child: Text("Snap"),
            style: ButtonStyle(
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  side: BorderSide(width: 10, color: HavkaColors.green)
              )),
              padding: MaterialStatePropertyAll(EdgeInsets.all(30.0)),
              backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.6)),
            ),
            onPressed: () async {
              await _initializeControllerFuture;
              final image = await _cameraController.takePicture();
              if (!mounted) return;
              await Navigator.of(context).push(
                TransparentPageRoute(
                    ReceiptAnalysingScreen(
                      imagePath: image.path,
                    )
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
