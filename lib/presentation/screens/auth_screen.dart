import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/core/constants/colors.dart';
import '/core/constants/privacy_policy.dart';
import '/core/constants/terms_of_use.dart';
import '/presentation/widgets/barcode.dart';
import '/presentation/widgets/button.dart';
import '/presentation/widgets/progress_indicator.dart';
import '/presentation/widgets/rounded_button.dart';
import '/presentation/widgets/rounded_textfield.dart';
import '/presentation/widgets/screen_header.dart';
import 'package:havka/presentation/providers/auth_provider.dart';
import '/presentation/widgets/holder.dart';


enum SignContent { TermsOfUse, PrivacyPolicy }

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _isPolicyAccepted = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late AnimationController _animationButtonsController;

  String? usernameErrorText;
  String? passwordErrorText;
  late bool futureSignIn;

  Widget? body;

  @override
  void initState() {
    super.initState();

    _usernameFocusNode.addListener(_onFocusEmail);
    _passwordFocusNode.addListener(_onFocusPassword);

    usernameErrorText = null;
    passwordErrorText = null;


    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();

    _animationButtonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
  }

  @override
  void dispose() {
    _animationButtonsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusEmail() {
    if (_usernameFocusNode.hasFocus) {
      usernameErrorText = null;
    }
  }

  void _onFocusPassword() {
    if (_passwordFocusNode.hasFocus) {
      passwordErrorText = null;
    }
  }

  // void _validateEmail() {
    // if (!_isPolicyAccepted && !_isLogin) {
    //   return SignInStatus.notLoggedIn;
    // }
    // if (emailController.text.isEmpty && passwordController.text.isEmpty) {
    //   emailErrorText = "Fill your email here";
    //   passwordErrorText = "Fill your password here";
    //   return SignInStatus.notLoggedIn;
    // }
    // if (emailController.text.isEmpty) {
    //   emailErrorText = "Fill your email here";
    //   return SignInStatus.notLoggedIn;
    // }
    // if (passwordController.text.isEmpty) {
    //   passwordErrorText = "Fill your password here";
    //   return SignInStatus.notLoggedIn;
    // }
    // if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
    //     .hasMatch(emailController.text)) {
    //   emailErrorText = "Use example@example.com";
    //   return SignInStatus.notLoggedIn;
    // }
    // usernameErrorText = null;
    // passwordErrorText = null;
    // return SignInStatus.logging;
  // }

  Future<void> _showSignContent(SignContent content) async {
    return await showModalBottomSheet(
      useRootNavigator: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (
            BuildContext context,
            ScrollController scrollController,
          ) {
            return ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0), // Adjust the radius as needed
                topRight: Radius.circular(20.0),
              ),
              child: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Holder(
                        height: 30,
                      ),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.9
                              - 30
                              - MediaQuery.of(context).padding.bottom,
                          child: Scrollbar(
                            controller: scrollController,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: NotificationListener<
                                    DraggableScrollableNotification>(
                                  onNotification: (notification) {
                                    return notification.extent > 0.5;
                                  },
                                  child: Builder(builder: (context) {
                                    switch (content) {
                                      case SignContent.TermsOfUse:
                                        return TermsOfUse();
                                      case SignContent.PrivacyPolicy:
                                        return PrivacyPolicy();
                                    }
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom) *
                      0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 80,
                              child: CustomPaint(
                                painter: HavkaBarcode(),
                                child: Container(),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, -0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _isLogin
                                  ? ScreenHeader(
                                text: "Sign In",
                                key: ValueKey<String>("SignIn"),
                              )
                                  : ScreenHeader(
                                text: "Sign Up",
                                key: ValueKey<String>("SignUp"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            RoundedTextField(
                              hintText: "Email",
                              controller: _usernameController,
                              focusNode: _usernameFocusNode,
                              textCapitalization: TextCapitalization.none,
                              descriptionText: Text(
                                usernameErrorText ?? "",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              onSubmitted: (_) {
                                _passwordFocusNode.requestFocus();
                              },
                            ),
                            RoundedTextField(
                              hintText: "Password",
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textCapitalization: TextCapitalization.none,
                              descriptionText: Text(
                                passwordErrorText ?? "",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              obscureText: true,
                              onSubmitted: (_) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (_isLogin) {
                                  authProvider.login(context, _usernameController.text, _passwordController.text);
                                } else {
                                  if(_isPolicyAccepted) {
                                    authProvider.signUp(_usernameController.text, _passwordController.text);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom) *
                      0.5,
                  child: authProvider.isLoading
                      ? Center(child: HavkaProgressIndicator())
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _isLogin
                          ? SizedBox.shrink()
                          : Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 20,
                                  child: Checkbox(
                                    value: _isPolicyAccepted,
                                    checkColor: Colors.white,
                                    onChanged: (value) {
                                      setState(() {
                                        _isPolicyAccepted = value!;
                                      });
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text("I accept "),
                                    InkWell(
                                      onTap: () => _showSignContent(SignContent.TermsOfUse),
                                      child: Text(
                                        "Terms of Use",
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                          TextDecoration.underline,
                                          decorationStyle:
                                          TextDecorationStyle.dashed,
                                          decorationColor: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                ),
                                Text("and "),
                                InkWell(
                                  onTap: () => _showSignContent(SignContent.PrivacyPolicy),
                                  child: Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      decoration:
                                      TextDecoration.underline,
                                      decorationStyle:
                                      TextDecorationStyle.dashed,
                                      decorationColor: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: RoundedButton(
                          text: _isLogin ? "Sign In" : "Sign Up",
                          color: _isLogin
                              ? HavkaColors.green
                              : _isPolicyAccepted
                                ? HavkaColors.green
                                : Colors.black.withValues(alpha: 0.2),
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (_isLogin) {
                              authProvider.login(context, _usernameController.text, _passwordController.text);
                            } else {
                              if(_isPolicyAccepted) {
                                authProvider.signUp(_usernameController.text, _passwordController.text);
                              }
                            }
                          },
                        ),
                      ),
                      Column(
                        children: [
                          Platform.isIOS
                              ? Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, -0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _isLogin
                                  ? AppleSignInButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => authProvider.loginWithApple(_usernameController.text),
                              )
                                  : SizedBox.shrink(),
                            ),
                          ) : SizedBox.shrink(),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, -0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _isLogin
                                  ? GoogleSignInButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => authProvider.loginWithGoogle(),
                              )
                                  : SizedBox.shrink(),
                            ),
                          ),
                          Hero(
                            tag: "get-started",
                            child: Container(
                              margin: EdgeInsets.only(top: 20.0),
                              child: HavkaButton(
                                fontSize: 18,
                                child: Align(child: Text("About Havka")),
                                onPressed: () {
                                  context.go("/about");
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _animationController.reset();
                                  _animationController.forward();
                                  usernameErrorText = null;
                                  passwordErrorText = null;
                                });
                              },
                              child: HavkaText(
                                  text: _isLogin ? "Sign Up" : "Sign In"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
