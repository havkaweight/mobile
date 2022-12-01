import 'package:flutter/material.dart';

import '../../splash/splash_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/sign_in_screen.dart';

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String signin = '/signin';
  static const String profile = '/profile';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    signin: (BuildContext context) => SignInScreen(),
    profile: (BuildContext context) => ProfileScreen(),
  };
}