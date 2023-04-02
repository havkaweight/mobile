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

enum SignInStatus {
  notLoggedIn,
  logging,
  loggedIn,
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;
  late SignInStatus signInStatus;
  List<String> _signings = [
    "Sign In",
    "Sign Up",
  ];
  late List<Function> _signingsFunctions;

  late final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<Offset> _animationSlideOut;
  late Animation<Offset> _animationSlideIn;
  late Animation<double> _animationFadeOut;
  late Animation<double> _animationFadeIn;

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animationSlideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.2),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationSlideIn = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationFadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  SignInStatus _validateEmail() {
    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      emailErrorText = 'Fill your email here';
      passwordErrorText = 'Fill your password here';
      return SignInStatus.notLoggedIn;
    }
    if (emailController.text.isEmpty) {
      emailErrorText = 'Fill your email here';
      return SignInStatus.notLoggedIn;
    }
    if (passwordController.text.isEmpty) {
      passwordErrorText = 'Fill your password here';
      return SignInStatus.notLoggedIn;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
        .hasMatch(emailController.text)) {
      emailErrorText = 'Use example@example.com';
      return SignInStatus.notLoggedIn;
    }
    emailErrorText = null;
    passwordErrorText = null;
    return SignInStatus.logging;
  }

  Future _signIn() async {
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

  Future _signUp() async {
    try {
      futureSignIn = await _apiRoutes.signUp(
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
                  Hero(
                    tag: "to-signin",
                    child: Stack(
                      children: [
                        FadeTransition(
                          opacity: _animationFadeOut,
                          child: SlideTransition(
                            position: _animationSlideOut,
                            child: ScreenHeader(
                              text: _signings.first,
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _animationFadeIn,
                          child: SlideTransition(
                            position: _animationSlideIn,
                            child: ScreenHeader(
                              text: _signings.last,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  RoundedTextField(
                    errorText: emailErrorText,
                    hintText: 'Email',
                    controller: emailController,
                    focusNode: _emailFocusNode,
                    onSubmitted: (_) {
                      setState(() => signInStatus = _validateEmail());
                      if (signInStatus == SignInStatus.logging) {
                        _signingsFunctions.first();
                      }
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
                      setState(() => signInStatus = _validateEmail());
                      if (signInStatus == SignInStatus.logging) {
                        _signingsFunctions.first();
                      }
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
            text: _signings.first,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => signInStatus = _validateEmail());
              if (_isSignIn) {
                if (signInStatus == SignInStatus.logging) {
                  _signingsFunctions.first();
                }
              } else {
                _signingsFunctions.last();
              }
            },
          ),
          if (_isSignIn)
            Column(
              children: [
                GoogleSignInButton(),
              ],
            )
          else
            Container(),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignIn = !_isSignIn;
                      // _signingsFunctions = _signingsFunctions.reversed.toList();
                      _animationController.reset();
                      _animationController.forward().whenComplete(() {
                        _signings = _signings.reversed.toList();
                      });
                      print(_signingsFunctions);
                    });
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SignUpScreen()),
                    //   (r) => false,
                    // );
                  },
                  child: HavkaText(text: _signings.last),
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
    _signingsFunctions = [
      _signIn,
      _signUp,
    ];
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
