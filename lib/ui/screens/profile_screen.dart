import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/components/profile.dart';
import 'package:health_tracker/ui/screens/child_widget.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:http/http.dart' as http;
import 'authorization.dart';
import '../../model/user.dart';
import '../../main.dart';
import 'devices_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  ApiRoutes _apiRoutes = ApiRoutes();

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
                  widget = Center(
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
        padding: EdgeInsets.symmetric(
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
                      GoogleSignIn _googleSignIn = GoogleSignIn();
                      _googleSignIn.disconnect();
                    });
                  }
              ),
              Text(
                'My id: ${snapshot.data.id}',
                style: TextStyle(
                    color: Color(0xFF5BBE78),
                    fontSize: 20
                ),
              ),
              Text(
                'My password hashed: ${snapshot.data.email}',
                style: TextStyle(
                  color: Color(0xFF5BBE78),
                  fontSize: 20,
                ),
              ),
              FutureBuilder<dynamic>(
                future: _apiRoutes.getUserDevicesList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData)
                    return Center(
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
                  return Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        children: <Widget>[
                          Text('No devices added :-('),
                          RoundedButton(
                              text: 'Add scale',
                              onPressed: () {
                                _buildScaleSearching();
                              }
                          )
                        ]
                      )
                    ),
                  );
                },
              ),
            ]
        )
    );
  }

  Future<dynamic> _buildScaleSearching() {
    return showModalBottomSheet(
      context: context, builder: (builder) {
        double mWidth = MediaQuery.of(context).size.width;
        double mHeight = MediaQuery.of(context).size.height;
        return Container(
          width: mWidth,
          height: mHeight * 0.75,
          child: DevicesScreen()
        );
      }
    );
  }

}