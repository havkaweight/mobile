import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_tracker/addons/google_sign_in/google_sign_in/lib/google_sign_in.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/ui/screens/sign_up_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:health_tracker/ui/screens/google_sign_in.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';

bool futureSignIn = true;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  ApiRoutes _apiRoutes = ApiRoutes();

  Widget body;

  @override
  void initState() {
    super.initState();
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

  Widget loginFormWidget (context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 50.0),
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ScreenHeader(text: 'Sign In'),
                  RoundedTextField(
                    hintText: 'Email',
                    controller: emailController,
                  ),
                  RoundedTextField(
                      hintText: 'Password',
                      obscureText: true,
                      controller: passwordController
                  ),
                  futureSignIn ? Container() : Text("wrong login or password"),
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
                              ])
                      ),
                      RoundedButton(
                          text: 'Continue with Google',
                          color: Color(0xFFEDE88E),
                          textColor: Theme.of(context).accentColor,
                          onPressed: () async {
                            GoogleSignIn _googleSignIn = GoogleSignIn(
                              // clientId: '192633702539-43vof2btppdn077h80k06e3mu72ut4lc.apps.googleusercontent.com',
                                scopes:[
                                  'email',
                                  'profile'
                                ]
                            );

                            final result = await _googleSignIn.signIn();
                            final ggAuth = await result.authentication;

                            var idToken = ggAuth.idToken;
                            var accessToken = ggAuth.accessToken;
                            var serverAuthCode = ggAuth.serverAuthCode;

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
                            // Navigator.push(context, MaterialPageRoute(
                            //     builder: (context) =>));
                          }
                          )
                ],
            )
        ),
    );
  }

  @override
  Widget build (BuildContext context) {
    // futureSignIn = true;
    print(futureSignIn);
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: loginFormWidget(context)
    );
  }

  //       : FutureBuilder<String>(
  //           future: _futureSignIn,
  //           builder: (context, snapshot) {
  //             if (snapshot.hasData) {
  //               return Scaffold (
  //                 body: Center(
  //                     child: Text(
  //                       snapshot.data,
  //                       style: TextStyle(
  //                         color: Color(0xFF00FF00),
  //                         fontSize: 25
  //                       )
  //                     )
  //                 )
  //               );
  //             } else if (snapshot.hasError) {
  //               return Text("${snapshot.error}");
  //             }
  //             return CircularProgressIndicator();
  //           },
  //         )
  //       ),
  //     )
  //   );
  // }
}