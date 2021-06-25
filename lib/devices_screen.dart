import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:http/http.dart' as http;
import 'constants/api.dart';
import 'authorization.dart';
import 'model/device.dart';

final MIBFS = '0000181b-0000-1000-8000-00805f9b34fb';
final serviceUUID2 = Uuid.parse(MIBFS);

class DevicesScreen extends StatefulWidget {
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {

  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> discDevicesList = [];
  final List<String> devicesListId = [];
  List<Uuid> devicesServiceUUID = [serviceUUID2];

  var _subscription;

  @override
  void initState() {
    super.initState();
  }

  Future _setSearchingDevicesList() async {
    final token = await storage.read(key: 'jwt');
    print('Before: $token');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}/devices/'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    // print('After: $token');
    final devices = jsonDecode(response.body);
    List<Device> devicesList = devices.map<Device>((json) {
      return Device.fromJson(json);
    }).toList();

    // print(devicesServiceUUID);
    for (Device device in devicesList) {
      devicesServiceUUID.add(Uuid.parse(device.serviceUUID));
    }
    print(devicesServiceUUID);

    _subscription = flutterReactiveBle.scanForDevices(
      withServices: devicesServiceUUID,
      // withServices: [],
      // requireLocationServicesEnabled: false,
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (!devicesListId.contains(device.id)) {
        print(device);
        setState(() {
          discDevicesList.add(device);
          devicesListId.add(device.id);
        });
      }
    }, onError: (e) {
      print('Device scan fails with error: $e');
    });
  }
  //
  // Future _addDevice(device) async {
  //   print(jsonEncode(device.toJson()));
  //   final token = await storage.read(key: 'jwt');
  //   final http.Response _ = await http.post(
  //       Uri.https(SERVER_IP, '$API_PREFIX/users/me/devices/add/'),
  //       headers: <String, String>{
  //         'Content-type': 'application/json',
  //         'Accept': 'application/json',
  //         // 'Content-Type': 'application/x-www-form-urlencoded',
  //         'Authorization': 'Bearer $token'
  //       },
  //       body: jsonEncode(device.toJson())
  //   );
  // }
  //
  ListView _buildListViewOfDevices() {
    List<Container> containers = [];
    for (DiscoveredDevice device in discDevicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              TextButton(
                // color: Colors.blue,
                child: Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  await _subscription?.cancel();
                  flutterReactiveBle.connectToDevice(id: device.id
                  ).listen((connectionState) {
                    print('here');
                  }, onError: (Object error){
                    print('error');
                  });
                  var res = await flutterReactiveBle.discoverServices(device.id);
                  print(res);
                  for (DiscoveredService serv in res) {
                    for (Uuid q in serv.characteristicIds) {
                      print('${serv.serviceId}, ${q.toString()}');
                      QualifiedCharacteristic qchr = QualifiedCharacteristic(
                          characteristicId: q,
                          serviceId: serv.serviceId,
                          deviceId: device.id);
                      var chr = await flutterReactiveBle.readCharacteristic(qchr);
                      print(chr);
                      String strng = '';
                      for (int s in chr) {
                        strng += String.fromCharCode(s);
                      }
                      print(strng);
                    }
                  }
                }
              )
              //     try {
              //       await device.connect();
              //     } catch (e) {
              //       if (e.code != 'already_connected') {
              //         throw e;
              //       }
              //     } finally {
              //       bluetoothServices = await device.discoverServices();
              //     }
              //     setState(() {
              //       connectedDevice = device;
              //     });
              //   },
              // ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() => _buildListViewOfDevices();

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _setSearchingDevicesList(),
      builder: (context, snapshot) {
        return Scaffold (
          backgroundColor: Theme.of(context).backgroundColor,
          body:
          // Center(
          //   child: Container(
          //     padding: EdgeInsets.symmetric(vertical: 40.0),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         ScreenHeader(
          //           text: 'Devices'
          //         ),
          //         // RoundedButton(
          //         //   text: 'Stop',
          //         //   // onPressed: widget.tflutterReactiveBle,
          //         // )
                  _buildView()
        );
      }
    );
  }

}