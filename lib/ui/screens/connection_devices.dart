// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//
// final scaleServiceUUID = 'f5ff08da-50b0-4a3e-b5e8-83509e584475';
// // final MIBFS = '0000181b-0000-1000-8000-00805f9b34fb';
// final scaleCharacteristicUUID = '25dbb242-e59b-452c-9a04-c37bdb92e00a';
// final scaleServiceUUIDData = 'lolkek';
// final serviceUUID = Uuid.parse(scaleServiceUUID);
// final serviceUUID2 = Uuid.parse(MIBFS);
//
// class DevicesScreen extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<DevicesScreen> {
//   final flutterReactiveBle = FlutterReactiveBle();
//   final List<DiscoveredDevice> devicesList = [];
//   final List<String> devicesListId = [];
//
//   @override
//   void initState() {
//     super.initState();
//     flutterReactiveBle.scanForDevices(
//       withServices: [serviceUUID],
//       scanMode: ScanMode.lowLatency,
//     ).listen((device) {
//       if (!devicesListId.contains(device.id)) {
//         print(device);
//         print(serviceUUID);
//         var a = serviceUUID.data;
//         print('data $a');
//         setState(() {
//           devicesList.add(device);
//           devicesListId.add(device.id);
//         });
//       }
//
//     }, onError: (e) {
//       print('Device scan fails with error: $e');
//     });
//   }
//
//   ListView _buildListViewOfDevices() {
//     List<Container> containers = [];
//     for (DiscoveredDevice device in devicesList) {
//       containers.add(
//         Container(
//           height: 50,
//           child: Row(
//             children: <Widget>[
//               Expanded(
//                 child: Column(
//                   children: <Widget>[
//                     Text(device.name == '' ? '(unknown device)' : device.name),
//                     Text(device.id.toString()),
//                   ],
//                 ),
//               ),
//               // FlatButton(
//               //   color: Colors.blue,
//               //   child: Text(
//               //     'Connect',
//               //     style: TextStyle(color: Colors.white),
//               //   ),
//               //   onPressed: () async {
//               //     flutterBlue.stopScan();
//               //     try {
//               //       await device.connect();
//               //     } catch (e) {
//               //       if (e.code != 'already_connected') {
//               //         throw e;
//               //       }
//               //     } finally {
//               //       bluetoothServices = await device.discoverServices();
//               //     }
//               //     setState(() {
//               //       connectedDevice = device;
//               //     });
//               //   },
//               // ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return ListView(
//       padding: const EdgeInsets.all(8),
//       children: <Widget>[
//         ...containers,
//       ],
//     );
//   }
//
//   ListView _buildView() {
//     // if (connectedDevice != null) {
//     //   return _buildConnectDeviceView();
//     // }
//     return _buildListViewOfDevices();
//   }
//   //
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(
//       title: Text("Bluetooth Demo"),
//     ),
//     body: _buildView(),
//   );
// }
