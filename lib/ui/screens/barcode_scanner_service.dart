import 'dart:async';
import 'package:flutter/services.dart';

enum ScanMode { QR, BARCODE, DEFAULT }

class BarcodeScanner {
  static const MethodChannel _channel =
      MethodChannel('flutter_barcode_scanner');

  // static const EventChannel _eventChannel =
  //     EventChannel('flutter_barcode_scanner_receiver');

  // static Stream? _onBarcodeReceiver;

  Future<String?> scanBarcode(ScanMode scanMode) async {
    final Map params = <String, dynamic>{'scanMode': scanMode.index};

    final String barcodeResult =
        await _channel.invokeMethod('scanBarcode', params) ?? '';
    return barcodeResult;
  }
}
