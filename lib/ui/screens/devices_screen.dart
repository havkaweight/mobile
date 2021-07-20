import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/model/device.dart';

Stream stream;
QualifiedCharacteristic characteristic;

Uuid serviceUuid = Uuid.parse(Scale.serviceUuid);
Uuid characteristicId = Uuid.parse(Scale.characteristicId);

class DevicesScreen extends StatefulWidget {
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {

  final List<DiscoveredDevice> discDevicesList = [];
  final List<String> devicesListId = [];
  List<Uuid> acceptedServiceUUID = [serviceUuid];

  final ApiRoutes _apiRoutes = ApiRoutes();

  var _subscription;

  @override
  void initState() {
    super.initState();
  }

  Future connectToDevice(DiscoveredDevice device) async {
    await _subscription?.cancel();
    stream = flutterReactiveBle.connectToDevice(id: device.id);
    characteristic = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: characteristicId, deviceId: device.id);

    final UserDeviceCreate userDeviceCreate = UserDeviceCreate(
      serviceUUID: serviceUuid.toString(),
      deviceUUID: characteristicId.toString()
    );
    final userDevice = await _apiRoutes.userDeviceAdd(userDeviceCreate);
    print(userDevice);
  }

  Future _setSearchingDevicesList() async {
    acceptedServiceUUID.add(serviceUuid);
    print(acceptedServiceUUID);

    _subscription = flutterReactiveBle.scanForDevices(
      withServices: acceptedServiceUUID,
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

  ListView _buildDevicesList() {
    final List<Container> containers = [];
    for (final DiscoveredDevice device in discDevicesList) {
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
                onPressed: () {
                  setState(() {
                    connectToDevice(device);
                    Navigator.pop(context);
                  });
                },
                // color: Colors.blue,
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Colors.black),
                )
              )
            ]
          )
        )
      );
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _setSearchingDevicesList(),
      builder: (context, snapshot) {
      if ([BleStatus.unauthorized, BleStatus.poweredOff, BleStatus.unsupported].contains(flutterReactiveBle.status) || flutterReactiveBle.status == BleStatus.locationServicesDisabled) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.bluetooth_disabled, color: Colors.grey,
                        size: 40),
                    Icon(Icons.location_disabled, color: Colors.grey,
                        size: 40),
                  ],
                ),
              ),
              const Text('Turn on Bluetooth and Location')
            ]
          )
        );
      }
      return Scaffold(
          backgroundColor: Theme
              .of(context)
              .backgroundColor,
          body: _buildDevicesList()
      );
      }
    );
  }

}