import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/ui/screens/sign_up_screen.dart';
import 'package:health_tracker/ui/widgets/button.dart';
import 'package:health_tracker/ui/widgets/popup.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield_obscure.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum SignInStatus { notLoggedIn, logging, loggedIn }

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final ApiRoutes _apiRoutes = ApiRoutes();
  late SignInStatus signInStatus = SignInStatus.notLoggedIn;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  String? emailErrorText;
  String? passwordErrorText;
  late bool futureSignIn;

  Widget? body;

  @override
  void initState() {
    super.initState();
    signInStatus = SignInStatus.notLoggedIn;
    _emailFocusNode.addListener(_onFocusEmail);
    _passwordFocusNode.addListener(_onFocusPassword);
    emailErrorText = null;
    passwordErrorText = null;
    futureSignIn = false;
  }

  Future<dynamic> resetPassword(String email) async {
    final Map<String, dynamic> body = {'email': email};
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };
    final http.Response response = await http.post(
      Uri.https(Api.host, '${Api.prefix}/auth/reset-password'),
      headers: headers,
      body: body,
    );

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == HttpStatus.ok) {
      if (data.containsKey('access_token')) {
        setToken(data['access_token'] as String);
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      print(response.body);
      throw Exception('Failed sign in');
    }
  }

  Future<Future> googleSignIn(String username, String password) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{};
    queryParameters['authentication_backend'] = 'jwt';
    queryParameters['scopes'] = ['email', 'profile'];
    final http.Response response = await http.post(
      Uri.https(Api.host, '${Api.prefix}/auth/google', queryParameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data.containsKey('access_token') != null) {
        setToken(data['access_token'] as String);
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      print(response.body);
      throw Exception('Failed sign in');
    }
  }

  void _onFocusEmail() {
    if (_emailFocusNode.hasFocus) {
      emailErrorText = null;
    }
  }

  void _onFocusPassword() {
    if (_passwordFocusNode.hasFocus) {
      passwordErrorText = null;
    }
  }

  _validateEmail() {
    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      emailErrorText = 'Fill your email here';
      passwordErrorText = 'Fill your password here';
      return;
    }
    if (emailController.text.isEmpty) {
      emailErrorText = 'Fill your email here';
      return;
    }
    if (passwordController.text.isEmpty) {
      passwordErrorText = 'Fill your password here';
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
        .hasMatch(emailController.text)) {
      emailErrorText = 'Use example@example.com';
      return;
    }
    return _signIn();
  }

  Future _signIn() async {
    setState(() {
      signInStatus = SignInStatus.logging;
    });
    try {
      futureSignIn = await _apiRoutes.signIn(
        emailController.text,
        passwordController.text,
      );
      setState(() {
        if (futureSignIn) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (r) => false,
          );
        } else {
          emailErrorText = 'Please check your email';
          passwordErrorText = 'Please check your password';
          signInStatus = SignInStatus.notLoggedIn;
        }
      });
    } catch (error) {
      setState(() {
        signInStatus = SignInStatus.notLoggedIn;
      });
    }
  }

  Widget loginFormWidget(BuildContext context) {
    final mHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: mHeight * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Hero(
                    tag: "to-signin",
                    child: ScreenHeader(text: 'Sign In'),
                  ),
                  RoundedTextField(
                    errorText: emailErrorText,
                    hintText: 'Email',
                    controller: emailController,
                    focusNode: _emailFocusNode,
                    onSubmitted: (_) {
                      setState(() => _validateEmail());
                      _passwordFocusNode.requestFocus();
                    },
                  ),
                  RoundedTextFieldObscured(
                    errorText: passwordErrorText,
                    hintText: 'Password',
                    controller: passwordController,
                    focusNode: _passwordFocusNode,
                    onSubmitted: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() => _validateEmail());
                    },
                  ),
                ],
              ),
            ),
            // if (futureSignIn) Container() else const Text("Wrong login or password"),
            SizedBox(
              height: mHeight * 0.4,
              child: bottomSignInNavigation(),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomSignInNavigation() {
    if (signInStatus == SignInStatus.notLoggedIn) {
      return Column(
        children: [
          RoundedButton(
            text: 'Sign In',
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => _validateEmail());
            },
          ),
          GoogleSignInButton(),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                      (r) => false,
                    );
                  },
                  child: const HavkaText(text: 'Sign Up'),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const Center(child: HavkaProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).backgroundColor,
        body: loginFormWidget(context),
      ),
    );
  }
}
