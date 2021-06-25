import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_tracker/sign_up_screen.dart';
import 'package:health_tracker/widgets/rounded_button.dart';
import 'authorization.dart';
import 'constants/api.dart';
import 'widgets/rounded_textfield.dart';
import 'widgets/screen_header.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'google_sign_in.dart';
import 'main_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Future<String> _futureSignIn;

  @override
  void initState() {
    super.initState();
  }

  authorizationError() {
    setState(() {

    });
  }

  Future<String> signIn(email, password) async {
    var pwdBytes = utf8.encode(password);
    var pwdHashed = sha256.convert(pwdBytes);
    print(pwdHashed);
    var map = Map<String, dynamic>();
    map['username'] = email;
    map['password'] = password;
    final http.Response response = await http.post(
      Uri.https(Api.host, '${Api.prefix}/auth/login'),
      headers: <String, String>{
        // 'Content-Type': 'application/json; charset=UTF-8'
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: map
    );

    print(response.body);
    print(response.statusCode);

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data.containsKey('access_token')) {
        setToken(data['access_token']);
        return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      // authorizationError();
      throw Exception('Failed sign in');
    }
  }

  Future<String> resetPassword(email) async {
    Map map = Map<String, dynamic>();
    map['email'] = email;
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}/auth/reset-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: map
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data.containsKey('access_token')) {
        setToken(data['access_token']);
        return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      print(response.body);
      throw Exception('Failed sign in');
    }
  }

  Future<String> googleSignIn(username, password) async {
    Map queryParameters = new Map<String, dynamic>();
    queryParameters['authentication_backend'] = 'jwt';
    queryParameters['scopes'] = ['email', 'profile'];
    final http.Response response = await http.post(
      Uri.https(Api.host, '${Api.prefix}/auth/google', queryParameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      }
    );

    print(response.body);
    print(response.statusCode);

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data.containsKey('access_token')) {
        setToken(data['access_token']);
        return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      print(response.body);
      throw Exception('Failed sign in');
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold (
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 70.0),
        child: Center(
          child: (_futureSignIn == null)
           ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScreenHeader(
                  text: 'Sign In'
              ),
              RoundedTextField(
                hintText: 'Email',
                controller: emailController,
              ),
              RoundedTextField(
                  hintText: 'Password',
                  obscureText: true,
                  controller: passwordController
              ),
              RoundedButton(
                text: 'Sign In',
                onPressed: () {
                  setState(() {
                    _futureSignIn = signIn(emailController.text, passwordController.text);
                  });
                },
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: TextButton(
                        child: CustomText(
                          text: 'Sign Up'
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                        },
                      )
                    ),
                    Container(
                      child: TextButton(
                        child: CustomText(
                          text: 'Reset password',
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                        },
                      )

                    )
                  ],
                )
              ),
              RoundedButton(
                text: 'Continue with Google',
                color: Color(0xFFEDE88E),
                textColor: Theme.of(context).accentColor,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SignInGoogleScreen()));
                }
              )
              // RoundedButton(
              //   text: 'Back',
              //   color: Color(0xFF5BBE78),
              //   onPressed: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              //   },
              // )
            ]
          )
        : FutureBuilder<String>(
            future: _futureSignIn,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scaffold (
                  body: Center(
                      child: Text(
                        snapshot.data,
                        style: TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 25
                        )
                      )
                  )
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          )
        ),
      )
    );
  }
}