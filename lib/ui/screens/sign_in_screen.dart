import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havka/api/constants.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/constants/privacy_policy.dart';
import 'package:havka/constants/terms_of_use.dart';
import 'package:havka/routes/sharp_page_route.dart';
import 'package:havka/ui/screens/authorization.dart';
import 'package:havka/ui/screens/main_screen.dart';
import 'package:havka/ui/screens/story_screen.dart';
import 'package:havka/ui/widgets/barcode.dart';
import 'package:havka/ui/widgets/button.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:havka/ui/widgets/rounded_button.dart';
import 'package:havka/ui/widgets/rounded_textfield.dart';
import 'package:havka/ui/widgets/screen_header.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../main.dart';
import '../../model/fridge.dart';
import '../widgets/holder.dart';

enum SignInStatus {
  notLoggedIn,
  logging,
  loggedIn,
}

enum SignContent { TermsOfUse, PrivacyPolicy }

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  bool _isSignIn = true;
  bool _isPolicyAccepted = false;
  late SignInStatus signInStatus;
  late List<Function> _signingsFunctions;

  late final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late AnimationController _animationButtonsController;

  String? emailErrorText;
  String? passwordErrorText;
  late bool futureSignIn;

  Widget? body;

  @override
  void initState() {
    super.initState();
    _signingsFunctions = [
      _signIn,
      _signUp,
    ];
    signInStatus = SignInStatus.notLoggedIn;
    _emailFocusNode.addListener(_onFocusEmail);
    _passwordFocusNode.addListener(_onFocusPassword);
    emailErrorText = null;
    passwordErrorText = null;
    futureSignIn = false;
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
    if (!_isPolicyAccepted && !_isSignIn) {
      return SignInStatus.notLoggedIn;
    }
    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      emailErrorText = "Fill your email here";
      passwordErrorText = "Fill your password here";
      return SignInStatus.notLoggedIn;
    }
    if (emailController.text.isEmpty) {
      emailErrorText = "Fill your email here";
      return SignInStatus.notLoggedIn;
    }
    if (passwordController.text.isEmpty) {
      passwordErrorText = "Fill your password here";
      return SignInStatus.notLoggedIn;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
        .hasMatch(emailController.text)) {
      emailErrorText = "Use example@example.com";
      return SignInStatus.notLoggedIn;
    }
    emailErrorText = null;
    passwordErrorText = null;
    return SignInStatus.logging;
  }

  Future _signIn() async {
    try {
      futureSignIn = await _apiRoutes.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      setState(() {
        if (futureSignIn) {
          GoRouter.of(context).go("/fridge");
        } else {
          emailErrorText = "Please check your email";
          passwordErrorText = "Please check your password";
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
        } else {
          signInStatus = SignInStatus.notLoggedIn;
        }
      });
    } catch (error) {
      debugPrint("Error $error");
      setState(() {
        signInStatus = SignInStatus.notLoggedIn;
      });
    }
    final Fridge? fridge = await _apiRoutes.createFridge();
    if (fridge != null) {
      final UserFridge userFridge =
          UserFridge(name: "Fridge", fridgeId: fridge.id!);
      await _apiRoutes.createUserFridge(userFridge: userFridge);
    }
  }

  Widget loginFormWidget(BuildContext context) {
    return SafeArea(
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
                          child: _isSignIn
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
                          controller: emailController,
                          focusNode: _emailFocusNode,
                          textCapitalization: TextCapitalization.none,
                          descriptionText: Text(
                            emailErrorText ?? "",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          onSubmitted: (_) {
                            setState(() => signInStatus = _validateEmail());
                            if (signInStatus == SignInStatus.logging) {
                              _signingsFunctions.first();
                            }
                            _passwordFocusNode.requestFocus();
                          },
                        ),
                        RoundedTextField(
                          hintText: "Password",
                          controller: passwordController,
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
                            setState(() => signInStatus = _validateEmail());
                            if (signInStatus == SignInStatus.logging) {
                              _signingsFunctions.first();
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
              child: signInStatus != SignInStatus.notLoggedIn
                  ? Center(child: HavkaProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _isSignIn
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
                            text: _isSignIn ? "Sign In" : "Sign Up",
                            color: _isSignIn
                                ? HavkaColors.green
                                : _isPolicyAccepted
                                    ? HavkaColors.green
                                    : Colors.black.withOpacity(0.2),
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() => signInStatus = _validateEmail());
                              if (_isSignIn) {
                                if (signInStatus == SignInStatus.logging) {
                                  _signingsFunctions.first();
                                }
                              } else {
                                if (_isPolicyAccepted) {
                                  _signingsFunctions.first();
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
                                child: _isSignIn
                                    ? AppleSignInButton(
                                  onPressed: () async {
                                    setState(() => signInStatus = SignInStatus.logging);
                                    final bool? status = await _appleSignIn();
                                    if (status == null) {
                                      setState(() => signInStatus = SignInStatus.notLoggedIn);
                                    }
                                  },
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
                                  child: _isSignIn
                                      ? GoogleSignInButton(
                                          onPressed: () async {
                                            setState(() {
                                              signInStatus =
                                                  SignInStatus.logging;
                                            });
                                            final bool? status = await _googleSignIn();
                                            if (status == null) {
                                              setState(() {
                                                signInStatus =
                                                    SignInStatus.notLoggedIn;
                                              });
                                            }
                                          },
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
                                    _isSignIn = !_isSignIn;
                                    _signingsFunctions =
                                        _signingsFunctions.reversed.toList();
                                    _animationController.reset();
                                    _animationController.forward();
                                    emailErrorText = null;
                                    passwordErrorText = null;
                                  });
                                },
                                child: HavkaText(
                                    text: _isSignIn ? "Sign Up" : "Sign In"),
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
    );
  }

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

  Future<bool?> _googleSignIn() async {
    final GoogleSignIn googleSignIn =
        GoogleSignIn(scopes: ['email', 'profile']);
    final googleAccount = await googleSignIn.signIn();
    if(googleAccount == null) {
      return null;
    }
    final googleAuth = await googleAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    if (googleAuth.accessToken != null && googleAuth.idToken != null) {
      await authInstance.signInWithCredential(credential);
      final bool isAuthSuccess =
      await ApiRoutes().signInGoogle(googleAuth.idToken!);
      if (isAuthSuccess) {
        final List<UserFridge> fridgesList =
        await ApiRoutes().getUserFridges();
        if (fridgesList.isEmpty) {
          final Fridge? fridge = await ApiRoutes().createFridge();
          if (fridge != null) {
            final UserFridge userFridge =
            UserFridge(name: "Fridge", fridgeId: fridge.id!);
            await ApiRoutes().createUserFridge(userFridge: userFridge);
          }
        }
        context.go("/fridge");
        return true;
      }
    }
    return false;
  }


  Future<bool?> _appleSignIn() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider("apple.com");
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final auth = await authInstance.signInWithCredential(credential);
      final bool isAuthSuccess =
      await _apiRoutes.signInApple(auth.user!.email!);
      if (isAuthSuccess) {
        final List<UserFridge> fridgesList =
        await _apiRoutes.getUserFridges();
        if (fridgesList.isEmpty) {
          final Fridge? fridge = await _apiRoutes.createFridge();
          if (fridge != null) {
            final UserFridge userFridge =
            UserFridge(name: "Fridge", fridgeId: fridge.id!);
            await _apiRoutes.createUserFridge(userFridge: userFridge);
          }
        }
        context.go("/fridge");
        return true;
      }
    } catch (SignInWithAppleAuthorizationException) {
      return null;
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: loginFormWidget(context),
      ),
    );
  }
}
