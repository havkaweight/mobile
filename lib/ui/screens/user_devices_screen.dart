import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/ui/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:health_tracker/ui/screens/devices_screen.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/model/user_device.dart';

class UserDevicesScreen extends StatefulWidget {
  @override
  _UserDevicesScreenState createState() => _UserDevicesScreenState();
}

class _UserDevicesScreenState extends State<UserDevicesScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> getUserDevicesList() async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}/users/me/devices'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(response.statusCode == 200) {
      final devices = jsonDecode(response.body);
      List<UserDevice> devicesList = devices.map<UserDevice>((json) {
        return UserDevice.fromJson(json);
      }).toList();
      return devicesList;
    } else {
      return 'No data';
    }
  }

  @override
  Widget build (BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.push((context), MaterialPageRoute(builder: (context) => ProfileScreen())),
      child: Scaffold (
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ScreenHeader(
                  text: 'My devices'
                ),
                RoundedButton(
                  text: 'Add device',
                  onPressed: () {},
                ),
                FutureBuilder<dynamic>(
                  future: getUserDevicesList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return Center(
                      child: Container(
                        child: HavkaProgressIndicator(),
                        padding: EdgeInsets.symmetric(vertical: 40.0)
                      )
                    );
                    if (snapshot.data.runtimeType == List)
                    return Expanded(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: snapshot.data.map<Widget>((data) {
                            return ListTile(
                              title: Text(data.deviceName),
                              subtitle: Text(data.deviceId.toString()),
                            );
                          }).toList(),
                        )
                    );
                    return Text('No data :-(');
                  },
                ),
              ])
          )
        )
      ),
    );
  }
}