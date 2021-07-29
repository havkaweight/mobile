
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/components/profile.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

import '../../model/user.dart';
import 'authorization.dart';
import 'devices_screen.dart';

final flutterReactiveBle = FlutterReactiveBle();

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold (
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: FutureBuilder<User>(
              future: _apiRoutes.getMe(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                Widget widget;
                if (!snapshot.hasData) {
                  widget = const Center(
                      child: HavkaProgressIndicator()
                  );
                } else if (snapshot.hasData) {
                  widget = _buildProfileScreen(snapshot);
                }
                if (snapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => SignInScreen()));
                  });
                }
                return widget;
              },
            ),
          ),
        )
      );
  }

  Widget _buildProfileScreen(AsyncSnapshot snapshot) {
    return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0, vertical: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileHeader(
                  username: '${snapshot.data.email}',
                  height: 163,
                  weight: 67,
                  photoUrl: 'https://i.pinimg.com/originals/ff/fc/5f/fffc5f9280b03622281eba858c3f14e5.jpg',
                  onPressed: () {
                    setState(() {
                      removeToken();
                      final GoogleSignIn _googleSignIn = GoogleSignIn();
                      _googleSignIn.disconnect();
                    });
                  }
              ),
              const ScreenSubHeader(
                text: 'My devices'
              ),
              FutureBuilder<dynamic>(
                future: _apiRoutes.getUserDevicesList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: const HavkaProgressIndicator()
                        )
                    );
                  }
                  print(snapshot.data.runtimeType);
                  if (snapshot.hasData) {
                    return Expanded(
                        child: ListView(
                          children: snapshot.data.map<Widget>((data) {
                            isDeviceConnected(data);
                            return ListTile(
                              title: Text(data.deviceName),
                              subtitle: Text(data.deviceId.toString()),
                            );
                          }).toList(),
                        )
                    );
                  }
                  return const Text('No devices added :-(');
                }
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedButton(
                        text: 'Add device',
                        onPressed: () {
                          _buildScaleSearching();
                          setState(() {});
                        }
                      ),
                      if ([BleStatus.unauthorized, BleStatus.poweredOff].contains(flutterReactiveBle.status)) const Icon(
                          Icons.bluetooth_disabled,
                          color: Colors.grey,
                        ) else const Icon(
                          Icons.bluetooth,
                          color: HavkaColors.green,
                        ),
                        if ([BleStatus.unauthorized, BleStatus.poweredOff].contains(flutterReactiveBle.status) || flutterReactiveBle.status == BleStatus.locationServicesDisabled) const Icon(
                        Icons.location_disabled,
                        color: Colors.grey,
                      ) else const Icon(
                        Icons.my_location,
                        color: HavkaColors.green,
                      )
                    ],
                  )
                )
              )
        ])
    );
  }

  Future<Widget> _buildScaleSearching() {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))
      ),
      context: context, builder: (builder) {
        final double mHeight = MediaQuery.of(context).size.height;
        return ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0)
          ),
          child: SizedBox(
            height: mHeight * 0.75,
            child: Column(
              children: [
                Holder(),
                Center(
                  child: DevicesScreen()
                )
              ]
            )
          ),
        );
      }
    );
  }

  Future<bool> isDeviceConnected(UserDevice userDevice) async {
    flutterReactiveBle.connectToDevice(id: userDevice.deviceUUID).listen((update) {
      bool status = false;
      if (update.connectionState == DeviceConnectionState.connected) {
        status = true;
      } else {
        status = false;
      };
      return status;
    });
  }

}