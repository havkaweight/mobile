import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/components/profile.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/device_service.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/weightings_screen.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

import '../../model/user.dart';
import 'authorization.dart';
import 'devices_screen.dart';
import 'products_screen.dart';

final flutterReactiveBle = FlutterReactiveBle();

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  // AppLifecycleState _notification;

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   setState(() { _notification = state; });
  //   print(_notification);
  // }

  @override
  Widget build(BuildContext context) {
    // flutterReactiveBle.statusStream.listen((status) {
    //   setState(() {});
    // });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        body: Center(
          child: FutureBuilder<User>(
            future: _apiRoutes.getMe(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget widget;
              if (!snapshot.hasData) {
                widget = const Center(child: HavkaProgressIndicator());
              } else if (snapshot.hasData) {
                widget = _buildProfileScreen(snapshot);
              }
              if (snapshot.hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                });
              }
              return widget;
            },
          ),
        ));
  }

  Widget _buildProfileScreen(AsyncSnapshot snapshot) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileHeader(
                  username: '${snapshot.data.email}',
                  height: 163,
                  weight: 67,
                  photoUrl:
                  'https://i.pinimg.com/originals/ff/fc/5f/fffc5f9280b03622281eba858c3f14e5.jpg',
                  onPressed: () {
                    setState(() {
                      removeToken();
                      final GoogleSignIn _googleSignIn = GoogleSignIn();
                      _googleSignIn.disconnect();
                    });
                  }),
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
                              padding:
                              const EdgeInsets.symmetric(vertical: 40.0),
                              child: const HavkaProgressIndicator()));
                    }
                    if (snapshot.hasData) {
                      return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, index) {
                                final UserDevice userDevice =
                                snapshot.data[index];
                                print(userDevice.macAddress);
                                return ListTile(
                                    title: Text(userDevice.userDeviceName,
                                        style: TextStyle(
                                            fontSize: Theme
                                                .of(context)
                                                .textTheme
                                                .headline3
                                                .fontSize)),
                                    subtitle: Text(userDevice.id.toString(),
                                        style: TextStyle(
                                            fontSize: Theme
                                                .of(context)
                                                .textTheme
                                                .headline4
                                                .fontSize)),
                                    trailing: StreamBuilder<ConnectionStateUpdate>(
                                      stream: flutterReactiveBle.connectToDevice(id: userDevice.macAddress.toUpperCase()),
                                      builder: (BuildContext context, AsyncSnapshot<ConnectionStateUpdate> snapshot) {
                                        String connectionStateText = 'Disconnected';
                                        Color connectionStateColor = HavkaColors.bone;
                                        if (snapshot.hasData) {
                                          print(snapshot.data);
                                          if (snapshot.data.connectionState ==
                                              DeviceConnectionState.connected) {
                                            connectionStateText = 'Connected';
                                            connectionStateColor =
                                                HavkaColors.green;
                                          } else {
                                            connectionStateText =
                                            'Disconnected';
                                            connectionStateColor = Colors.red;
                                          }
                                        }
                                        return Text(connectionStateText,
                                            style: TextStyle(
                                                color: connectionStateColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .headline4
                                                    .fontSize));
                                      },
                                    )
                                );
                              }));
                    }
                    return const Text('No devices added :-(');
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
                          if ([BleStatus.unauthorized, BleStatus.poweredOff]
                              .contains(flutterReactiveBle.status))
                            const Icon(
                              Icons.bluetooth_disabled,
                              color: Colors.grey,
                            )
                          else
                            const Icon(
                              Icons.bluetooth,
                              color: HavkaColors.green,
                            ),
                          if ([BleStatus.unauthorized, BleStatus.poweredOff]
                              .contains(flutterReactiveBle.status) ||
                              flutterReactiveBle.status ==
                                  BleStatus.locationServicesDisabled)
                            const Icon(
                              Icons.location_disabled,
                              color: Colors.grey,
                            )
                          else
                            const Icon(
                              Icons.my_location,
                              color: HavkaColors.green,
                            )
                        ],
                      )))
            ]));
  }

  Future _buildWeightingsHistory() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        context: context,
        builder: (BuildContext builder) {
          final double mHeight = MediaQuery
              .of(context)
              .size
              .height;
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

  Future<Widget> _buildScaleSearching(BuildContext context) async {
    final List<DeviceService> servicesList =
    await _apiRoutes.getDevicesServicesList();
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        context: context,
        builder: (builder) {
          final double mHeight = MediaQuery
              .of(context)
              .size
              .height;
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

  Future<bool> isDeviceConnected(UserDevice userDevice) async {
    flutterReactiveBle
        .connectToDevice(id: userDevice.serialId)
        .listen((update) {
      bool status = false;
      if (update.connectionState == DeviceConnectionState.connected) {
        status = true;
      } else {
        status = false;
      }
      ;
      return status;
    });
  }
}
