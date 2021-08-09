import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';

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

    final UserDevice userDevice = UserDevice(
      serviceUUID: serviceUuid.toString(),
      deviceUUID: characteristicId.toString()
    );
    final response = await _apiRoutes.userDeviceAdd(userDevice);
    print(response);
  }

  Future _setSearchingDevicesList() async {
    print(acceptedServiceUUID);

    _subscription = flutterReactiveBle.scanForDevices(
      withServices: acceptedServiceUUID,
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (!devicesListId.contains(device.id)) {
        print('tut');
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

  SizedBox _buildDevicesList() {
    final List<SizedBox> containers = [];
    for (final DiscoveredDevice device in discDevicesList) {
      containers.add(
        SizedBox(
          height: 50,
          child: Row(
            children: [
              ListTile(
                title: Text(device.name == '' ? '(unknown device)' : device.name),
                subtitle: Text(device.id.toString()),
              ),
            ],
          )
        )
      );
    }
    return SizedBox(
      child: Wrap(
        children: [ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ...containers,
          ],
        )],
      ),
    );
  }

  @override
  Widget build (BuildContext context) {
    return FutureBuilder(
      future: _setSearchingDevicesList(),
      builder: (context, snapshot) {
      final double mHeight = MediaQuery.of(context).size.height;
      if ([BleStatus.unauthorized, BleStatus.poweredOff, BleStatus.unsupported].contains(flutterReactiveBle.status) || flutterReactiveBle.status == BleStatus.locationServicesDisabled) {
        return SizedBox(
          height: mHeight * 0.73,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.bluetooth_disabled, color: Colors.grey,
                        size: 40),
                    Icon(Icons.location_disabled, color: Colors.grey,
                        size: 40),
                  ],
                ),
              ),
              const Text('Turn on Bluetooth and Location')
            ]
          ),
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