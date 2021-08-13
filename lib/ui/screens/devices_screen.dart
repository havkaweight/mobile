import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/constants/scale.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

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

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
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
    print('tut $acceptedServiceUUID');

    _subscription = flutterReactiveBle.scanForDevices(
      withServices: acceptedServiceUUID,
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      print(device.id);
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

  ListView _buildDevicesList(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: discDevicesList.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final DiscoveredDevice device = discDevicesList[index];
          return
              ListTile(
                title: Text(device.name == '' ? '(unknown device)' : device.name),
                subtitle: Text(device.id),
                trailing: TextButton(
                  onPressed: () {
                    connectToDevice(device);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: HavkaColors.green)
                  ),
                ),
              );
        }
    );
  }

  @override
  Widget build (BuildContext context) {
    final double mHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: mHeight * 0.82,
      child: FutureBuilder(
        future: _setSearchingDevicesList(),
        builder: (context, snapshot) {
        if ([BleStatus.unauthorized, BleStatus.poweredOff, BleStatus.unsupported].contains(flutterReactiveBle.status) || flutterReactiveBle.status == BleStatus.locationServicesDisabled) {
          return Column(
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
          );
        }
        return _buildDevicesList(context);
        }
      ),
    );
  }

}