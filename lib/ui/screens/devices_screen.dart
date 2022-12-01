import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../api/methods.dart';
import '../../constants/colors.dart';
import '../../constants/scale.dart';
import '../../constants/utils.dart';
import '../../model/device_service.dart';
import '../../model/user_device.dart';
import '../../ui/screens/profile_screen.dart';
import '../../ui/widgets/rounded_button.dart';

Stream stream;
QualifiedCharacteristic characteristic;

Uuid scaleServiceUuid = Uuid.parse(Scale.scaleServiceUuid);
Uuid scaleCharacteristicId = Uuid.parse(Scale.scaleCharacteristicId);

class DevicesScreen extends StatefulWidget {
  final List<DeviceService> servicesList;

  const DevicesScreen(this.servicesList);

  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  final List<DiscoveredDevice> discDevicesList = [];
  final List<String> devicesListId = [];

  // List<DeviceService> servicesList = [];

  List<Uuid> servicesUuidList = [];

  StreamSubscription<DiscoveredDevice> _subscription;

  @override
  void initState() {
    super.initState();
    servicesUuidList = widget.servicesList.map((deviceService) {
      return Uuid.parse(deviceService.serviceUuid);
    }).toList();
    servicesUuidList.add(Uuid.parse('0000181b-0000-1000-8000-00805f9b34fb'));
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  Future connectToDevice(DiscoveredDevice device) async {
    final Utils utils = Utils();
    await _subscription?.cancel();
    final DeviceService service = widget.servicesList.singleWhere(
        (serviceItem) =>
            Uuid.parse(serviceItem.serviceUuid) == device.serviceUuids[0]);
    final Uuid serviceUuid = Uuid.parse(service.serviceUuid);
    final Uuid characteristicUuid = Uuid.parse(service.characteristicUuid);
    // stream = flutterReactiveBle.connectToDevice(id: device.id);
    final _connectionStateUpdateSubscription = flutterReactiveBle.connectToDevice(id: device.id).listen(null);
    characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: device.id);
    final List<int> serialIdRaw =
        await flutterReactiveBle.readCharacteristic(characteristic);
    final String serialId = utils.listIntToString(serialIdRaw);
    print(serialIdRaw);
    print(serialId);
    await _connectionStateUpdateSubscription?.cancel(); // disconnecting
    await _apiRoutes.userDeviceAdd(serialId);
  }

  Future _setSearchingDevicesList() async {
    // servicesList = await _apiRoutes.getDevicesServicesList();
    // final List<Uuid> servicesUuidList = servicesList.map((deviceService) {
    //   return Uuid.parse(deviceService.serviceUuid);
    // }).toList();
    // servicesUuidList.add(Uuid.parse('0000181b-0000-1000-8000-00805f9b34fb'));
    print(servicesUuidList);
    _subscription = flutterReactiveBle
        .scanForDevices(
      withServices: servicesUuidList,
      scanMode: ScanMode.lowLatency,
    )
        .listen((device) {
      if (!devicesListId.contains(device.id)) {
        print(device.id);
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
          return ListTile(
            title: Text(device.name == '' ? '(unknown device)' : device.name),
            subtitle: Text(device.id),
            trailing: RoundedButton(
                text: 'Connect',
                onPressed: () {
                  connectToDevice(device);
                  Navigator.pop(context);
                }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final double mHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: mHeight * 0.82,
      child: FutureBuilder(
          future: _setSearchingDevicesList(),
          builder: (context, snapshot) {
            if ([
                  BleStatus.unauthorized,
                  BleStatus.poweredOff,
                  BleStatus.unsupported
                ].contains(flutterReactiveBle.status) ||
                flutterReactiveBle.status ==
                    BleStatus.locationServicesDisabled) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Icon(Icons.bluetooth_disabled,
                              color: Colors.grey, size: 40),
                          Icon(Icons.location_disabled,
                              color: Colors.grey, size: 40),
                        ],
                      ),
                    ),
                    const Text('Turn on Bluetooth and Location')
                  ]);
            }
            return _buildDevicesList(context);
          }),
    );
  }
}
