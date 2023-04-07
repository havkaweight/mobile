import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/devices_screen.dart';
import 'package:health_tracker/ui/screens/products_screen.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

import 'package:health_tracker/ui/widgets/holder.dart';

class BleStatusTrackingWidget extends StatefulWidget {
  final Widget? child;

  const BleStatusTrackingWidget({Key? key, this.child}) : super(key: key);

  @override
  BleStatusTrackingWidgetState createState() => BleStatusTrackingWidgetState();
}

class BleStatusTrackingWidgetState extends State<BleStatusTrackingWidget> {
  final ApiRoutes _apiRoutes = ApiRoutes();
  String macAddress = 'macAddress';
  String status = 'unk';

  PersistentBottomSheetController? _controller;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        backgroundColor: Theme.of(context).backgroundColor,
        body: widget.child);
    // body: FutureBuilder(
    // future: _apiRoutes.getUserDevicesList(),
    // builder: (BuildContext context,
    //     AsyncSnapshot<List<UserDevice>> snapshot) {
    //   final List<UserDevice> userDevicesList = snapshot.data;
    //   final UserDevice userDevice = userDevicesList[0];
    //   print(userDevice.macAddress);
    //
    //   flutterReactiveBle
    //       .connectToDevice(id: userDevice.macAddress.toUpperCase())
    //       .listen((event) {
    //     print(event.connectionState);
    //     status = event.connectionState.toString().split('.').last;
    //     if (event.connectionState == DeviceConnectionState.connected) {
    //       final QualifiedCharacteristic scaleCharacteristic =
    //           QualifiedCharacteristic(
    //               serviceId: scaleServiceUuid,
    //               characteristicId: scaleCharacteristicId,
    //               deviceId: userDevice.macAddress.toUpperCase());
    //       final Utils utils = Utils();
    //       macAddress = userDevice.macAddress;
    //       _controller = _key.currentState.showBottomSheet(
    //         (context) {
    //           final double mHeight = MediaQuery.of(context).size.height;
    //           final double mWidth = MediaQuery.of(context).size.width;
    //           return ClipRRect(
    //               borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    //               child: SizedBox(
    //                   height: mHeight * 0.1,
    //                   width: mWidth * 0.25,
    //                   child: Center(
    //                       child: StreamBuilder<List<int>>(
    //                           stream: flutterReactiveBle
    //                               .subscribeToCharacteristic(
    //                                   scaleCharacteristic),
    //                           builder: (BuildContext context,
    //                               AsyncSnapshot<List<int>> snapshot) {
    //                             if (!snapshot.hasData) {
    //                               return const HavkaProgressIndicator();
    //                             } else {
    //                               final String valueString = utils
    //                                   .listIntToString(snapshot.data);
    //                               final double weight =
    //                                   double.parse(valueString);
    //                               return HavkaText(text: '$weight g');
    //                             }
    //                           }))));
    //         },
    //         backgroundColor: HavkaColors.bone,
    //         shape: const RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(15.0))),
    //       );
    //     } else if (event.connectionState ==
    //         DeviceConnectionState.disconnected) {
    //       macAddress = 'macAddress';
    //       _controller.close();
    //       setState(() {});
    //     }
    //     print('$status $macAddress');
    //   });
    //   print('$status $macAddress');
    //   return widget.child;
    // }));
  }
}
