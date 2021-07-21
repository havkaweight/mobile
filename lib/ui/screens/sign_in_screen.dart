import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_tracker/addons/google_sign_in/google_sign_in/lib/google_sign_in.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/ui/screens/sign_up_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield_obscure.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:http/http.dart' as http;

bool futureSignIn = true;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiRoutes _apiRoutes = ApiRoutes();

  Widget body;

  @override
  void initState() {
    super.initState();
  }

  Future<String> resetPassword(String email) async {
    final Map map = <String, dynamic>{};
    map['email'] = email;
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}/auth/reset-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: map
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data.containsKey('access_token') != null) {
        setToken(data['access_token'] as String);
        return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      print(response.body);
      throw Exception('Failed sign in');
    }
  }

  Future<String> googleSignIn(String username, String password) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{};
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

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data.containsKey('access_token') != null) {
        setToken(data['access_token'] as String);
        return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      print(response.body);
      throw Exception('Failed sign in');
    }
  }

  Widget loginFormWidget(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const ScreenHeader(text: 'Sign In'),
                    RoundedTextField(
                      hintText: 'Email',
                      controller: emailController,
                    ),
                    RoundedTextFieldObscured(
                      hintText: 'Password',
                      controller: passwordController
                    ),
                    if (futureSignIn) Container() else const Text("Wrong login or password"),
                    RoundedButton(
                        text: 'Sign In',
                        onPressed: () async {
                          futureSignIn = await _apiRoutes.signIn(emailController.text, passwordController.text);
                          print('res $futureSignIn');
                          setState(() {
                            if (futureSignIn) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
                              });
                            }
                          });
                        }),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                                  },
                                  child: const HavkaText(
                                      text: 'Sign Up'
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                                  },
                                  child: const HavkaText(
                                    text: 'Reset password',
                                  ),
                                )
                                ])
                        ),
                        RoundedButton(
                            text: 'Continue with Google',
                            color: HavkaColors.cream,
                            textColor: Theme.of(context).accentColor,
                            onPressed: () async {
                              final GoogleSignIn _googleSignIn = GoogleSignIn(
                                  scopes:[
                                    'email',
                                    'profile'
                                  ]
                              );

                              final result = await _googleSignIn.signIn();
                              final ggAuth = await result.authentication;

                              final idToken = ggAuth.idToken;
                              final accessToken = ggAuth.accessToken;
                              final serverAuthCode = ggAuth.serverAuthCode;

                              print('id $idToken');
                              print('acs $accessToken');
                              print('code $serverAuthCode');

                              futureSignIn = await _apiRoutes.googleCallback(serverAuthCode);
                              print('res $futureSignIn');
                              setState(() {
                                if (futureSignIn) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
                                  });
                                }
                              });
                            }
                        )
                  ],
              )
          ),
    );
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: loginFormWidget(context)
    );
  }
}