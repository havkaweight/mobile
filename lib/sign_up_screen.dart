import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_tracker/sign_in_screen.dart';
import 'package:health_tracker/widgets/rounded_button.dart';
import 'package:health_tracker/widgets/rounded_textfield.dart';
import 'package:health_tracker/sign_in_check_screen.dart';
import 'constants/api.dart';
import 'widgets/screen_header.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:health_tracker/routes/horizontal_route.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Future<String> _futureSignUp;
  bool _userExists = false;
  String buttonText = 'Sign Up';

  _checkEmail() {
    Timer(Duration(seconds: 3), () async {
      print(emailController.text);
      // var url = 'https://maupars.ru/check_username.php?username=${usernameController.text}';
      final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}/users/${emailController.text}/check'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }
      );
      var data = jsonDecode(response.body);
      print(data);
      print(response.statusCode);
      print(_userExists);
      if (response.statusCode == 200 && data['user_exists'] == 'true') {
        print('here 1');
        setState(() {
          _userExists = true;
        });
      } else {
        setState(() {
          _userExists = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkEmail);
  }

  Future signUp(email, password) async {
    var pwdBytes = utf8.encode(password);
    var pwdHashed = sha256.convert(pwdBytes);
    print(pwdHashed);
    // var url = 'https://maupars.ru/signup.php?username=$username&password=$pwdHashed';
    // final http.Response response = await http.post(url);
    var map = new Map<String, dynamic>();
    map['email'] = email;
    map['password'] = password;
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password
        }),
        // body: map
    );

    if (response.statusCode == 201) {
      // setToken(password);
      return Navigator.push(context, HorizontalRoute(SignInCheckScreen()));
    }
    else {
      print(response.body);
      throw Exception('Failed sign up.');
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold (
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 70.0),
        child: Center(
          child: (_futureSignUp == null)
           ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScreenHeader(
                  text: 'Sign Up'
              ),
              RoundedTextField(
                hintText: 'Email',
                controller: emailController,
                errorText: _userExists ? 'User already exists' : null,
              ),
              RoundedTextField(
                hintText: 'Password',
                obscureText: true,
                controller: passwordController,
              ),
              RoundedButton(
                text: 'Sign Up',
                onPressed: () {
                  setState(() {
                    _futureSignUp = signUp(emailController.text, passwordController.text);
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
                                text: 'Sign In'
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                            },
                          )
                      ),
                      Container(
                          child: TextButton(
                            child: CustomText(
                              text: 'Reset password',
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                            },
                          )

                      )
                    ],
                  )
              ),
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
            future: _futureSignUp,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    snapshot.data,
                    style: TextStyle(
                      color: Color(0xFF5BBE78),
                      fontSize: 25
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
