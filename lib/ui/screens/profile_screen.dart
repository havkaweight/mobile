import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/components/profile.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:http/http.dart' as http;
import 'authorization.dart';
import '../../constants/api.dart';
import '../../model/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<User> getUserInfo() async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}/users/me'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    final user = User.fromJson(jsonDecode(response.body));
    return user;
  }

  @override
  Widget build (BuildContext context) {
    return WillPopScope(
      onWillPop: () => SystemNavigator.pop(),
      child: Scaffold (
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: FutureBuilder<User>(
              future: getUserInfo(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) return Center(
                    child: CircularProgressIndicator()
                );
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ProfileHeader(
                        username: '${snapshot.data.email}',
                        height: 163,
                        weight: 67,
                        photoUrl: 'https://i.pinimg.com/originals/ff/fc/5f/fffc5f9280b03622281eba858c3f14e5.jpg'
                      ),
                      Text(
                        'My id: ${snapshot.data.id}',
                        style: TextStyle(
                          color: Color(0xFF5BBE78),
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'My password hashed: ${snapshot.data.email}',
                        style: TextStyle(
                          color: Color(0xFF5BBE78),
                          fontSize: 20,
                        ),
                      )
                    ])
                );
              },
            ),
          ),
        )
      ),
    );
  }
}