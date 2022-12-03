import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/ui/screens/sign_in_check_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield_obscure.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Future<dynamic>? _futureSignUp;
  bool _userExists = false;
  String buttonText = 'Sign Up';

  void _checkEmail() {
    Timer(const Duration(seconds: 3), () async {
      print(emailController.text);
      // var url = 'https://maupars.ru/check_username.php?username=${usernameController.text}';
      final http.Response response = await http.get(
          Uri.https(
              Api.host, '${Api.prefix}/users/${emailController.text}/check'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      final data = jsonDecode(response.body);
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

  Future<dynamic> signUp(String? email, String? password) async {
    final pwdBytes = utf8.encode(password!);
    final pwdHashed = sha256.convert(pwdBytes);
    print(pwdHashed);
    // var url = 'https://maupars.ru/signup.php?username=$username&password=$pwdHashed';
    // final http.Response response = await http.post(url);
    final map = <String, dynamic>{};
    map['email'] = email;
    map['password'] = password;
    final http.Response response = await http.post(
      Uri.https(Api.host, '${Api.prefix}/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{"email": email!, "password": password}),
      // body: map
    );

    if (response.statusCode == 201) {
      // setToken(password);
      return Navigator.push(context,
          MaterialPageRoute(builder: (context) => SignInCheckScreen()));
    } else {
      print(response.body);
      throw Exception('Failed sign up.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 70.0),
          child: Center(
              child: (_futureSignUp == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          const ScreenHeader(text: 'Sign Up'),
                          RoundedTextField(
                            hintText: 'Email',
                            controller: emailController,
                            errorText:
                                _userExists ? 'User already exists' : '',
                          ),
                          RoundedTextFieldObscured(
                            hintText: 'Password',
                            controller: passwordController,
                          ),
                          RoundedButton(
                            text: 'Sign Up',
                            onPressed: () {
                              setState(() {
                                _futureSignUp = signUp(emailController.text,
                                    passwordController.text);
                              });
                            },
                          ),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInScreen()));
                                    },
                                    child: const HavkaText(text: 'Sign In'),
                                  )),
                                  Container(
                                      child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInScreen()));
                                    },
                                    child: const HavkaText(
                                      text: 'Reset password',
                                    ),
                                  ))
                                ],
                              )),
                          // RoundedButton(
                          //   text: 'Back',
                          //   color: Color(0xFF5BBE78),
                          //   onPressed: () {
                          //     Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                          //   },
                          // )
                        ])
                  : FutureBuilder<dynamic>(
                      future: _futureSignUp,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!.toString(),
                              style: const TextStyle(
                                  color: Color(0xFF5BBE78), fontSize: 25));
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const CircularProgressIndicator();
                      },
                    )),
        ));
  }
}
