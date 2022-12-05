import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import '../../api/methods.dart';
import '../../constants/colors.dart';
import '../../model/device_service.dart';
import '../../model/user_device.dart';
import '../screens/devices_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/weightings_screen.dart';
import 'holder.dart';

class UserDeviceList extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final double? width;
  final Color? color;
  final Icon? icon;
  final bool? obscureText;
  final bool? autoFocus;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const UserDeviceList({
    Key? key,
    this.labelText,
    this.hintText,
    this.width = 0.7,
    this.icon,
    this.color,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text
  }) : super(key: key);

  @override
  UserDeviceListState createState() => UserDeviceListState();
}

class UserDeviceListState<T extends UserDeviceList> extends State<UserDeviceList> {
  @override
  void initState() {
    super.initState();
  }

  final ApiRoutes _apiRoutes = ApiRoutes();

  Future _buildWeightingsHistory() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        context: context,
        builder: (BuildContext builder) {
          final double mHeight = MediaQuery.of(context).size.height;
          return SizedBox(
            height: mHeight * 0.85,
            child: Column(children: [
              Holder(),
              Center(
                  child: Column(
                    children: [
                      WeightingsScreen(),
                    ],
                  ))
            ]),
          );
        });
  }

  Future<dynamic> _buildScaleSearching(BuildContext context) async {
    final List<DeviceService> servicesList =
    await _apiRoutes.getDevicesServicesList();
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        context: context,
        builder: (builder) {
          final double mHeight = MediaQuery.of(context).size.height;
          return ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)),
            child: SizedBox(
                height: mHeight * 0.85,
                child: Column(children: [
                  Holder(),
                  Center(child: DevicesScreen(servicesList))
                ])),
          );
        });
  }

  Future<void> isDeviceConnected(UserDevice userDevice) async {
    flutterReactiveBle
        .connectToDevice(id: userDevice.serialId!)
        .listen((update) {
      bool status = false;
      if (update.connectionState == DeviceConnectionState.connected) {
        status = true;
      } else {
        status = false;
      }
      ;
      // return status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double mWidth = MediaQuery.of(context).size.width;
    return Container(
      width: widget.width! * mWidth,
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ScreenSubHeader(text: 'My devices'),
            IconButton(
                icon: const Icon(Icons.history),
                onPressed: _buildWeightingsHistory)
          ],
        ),
        FutureBuilder<List<UserDevice>>(
            future: _apiRoutes.getUserDevicesList(),
            builder: (BuildContext context,
                AsyncSnapshot<List<UserDevice>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: const HavkaProgressIndicator()));
              }
              if (snapshot.hasData) {
                return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, index) {
                          final UserDevice userDevice = snapshot.data![index];
                          return ListTile(
                              title: Text(userDevice.userDeviceName!,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .headline3!
                                          .fontSize)),
                              trailing: StreamBuilder<ConnectionStateUpdate>(
                                stream: flutterReactiveBle
                                    .connectToDevice(
                                    id: userDevice.macAddress!
                                        .toUpperCase())
                                    .asBroadcastStream(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<ConnectionStateUpdate>
                                    snapshot) {
                                  print(snapshot);
                                  String connectionStateText = 'Connected';
                                  Color connectionStateColor =
                                      HavkaColors.green;
                                  if (snapshot.hasData) {
                                    print(snapshot.data);
                                    if (snapshot.data!.connectionState ==
                                        DeviceConnectionState.connected) {
                                      connectionStateText = 'Connected';
                                      connectionStateColor =
                                          HavkaColors.green;
                                    }  else {
                                      connectionStateText = 'Disconnected';
                                      connectionStateColor = HavkaColors.bone;
                                    }
                                  }
                                  return Text(connectionStateText,
                                      style: TextStyle(
                                          color: connectionStateColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .fontSize));
                                },
                              ));
                        }));
              }
              return const HavkaText(text: 'No devices added :-(');
            }),
        Center(
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedButton(
                        text: 'Add device',
                        onPressed: () {
                          _buildScaleSearching(context)
                              .then((_) => setState(() {}));
                        }),
                    StreamBuilder<BleStatus>(
                        stream: flutterReactiveBle.statusStream,
                        builder: (BuildContext context, AsyncSnapshot<BleStatus> snapshot) {
                          if ([BleStatus.unauthorized, BleStatus.poweredOff]
                              .contains(snapshot.data)) {
                            return Row(children: const [
                              Icon(
                                Icons.bluetooth_disabled,
                                color: Colors.grey,
                              ),
                              Icon(
                                Icons.location_disabled,
                                color: Colors.grey,
                              )
                            ]
                            );
                          } else {
                            return Row(children: const [
                              Icon(
                                Icons.bluetooth,
                                color: HavkaColors.green,
                              ),
                              Icon(
                                Icons.my_location,
                                color: HavkaColors.green,
                              )
                            ]);
                          }
                        })
                  ],
                )))
      ],)
    );
  }
}
