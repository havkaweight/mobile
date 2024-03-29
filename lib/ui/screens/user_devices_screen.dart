import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/model/user_device.dart';

class UserDevicesScreen extends StatefulWidget {
  @override
  _UserDevicesScreenState createState() => _UserDevicesScreenState();
}

class _UserDevicesScreenState extends State<UserDevicesScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileScreen())),
      child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                const ScreenHeader(text: 'My devices'),
                RoundedButton(
                  text: 'Add device',
                  onPressed: () {},
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
                    if (snapshot.data.runtimeType == List) {
                      return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, index) {
                                final UserDevice userDevice =
                                    snapshot.data[index];
                                return ListTile(
                                  title: Text(userDevice.userDeviceName),
                                  subtitle:
                                      Text(userDevice.deviceId.toString()),
                                );
                              }));
                    }
                    return const Text('No data :-(');
                  },
                ),
              ]))),
    );
  }
}
