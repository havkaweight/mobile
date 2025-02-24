import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/core/constants/colors.dart';
import '/presentation/screens/authorization.dart';
import 'package:path_provider/path_provider.dart';

class DeveloperScreen extends StatefulWidget {
  @override
  _DeveloperScreenState createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  late bool notifications;
  Color buttonColor = HavkaColors.black.withValues(alpha: 0.05);

  @override
  void initState() {
    super.initState();
    notifications = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: HavkaColors.cream,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: Offset(0.0, 2.0),
                        blurRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Developer",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            // Text(
                            //   "Online",
                            //   style: TextStyle(
                            //       color: Colors.grey.shade600, fontSize: 13),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: HavkaColors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Push Notifications"),
                            CupertinoSwitch(
                              value: notifications,
                              onChanged: (bool value) async {
                                final messaging = FirebaseMessaging.instance;
                                NotificationSettings settings = await messaging.requestPermission(
                                  alert: true,
                                  announcement: false,
                                  badge: true,
                                  carPlay: false,
                                  criticalAlert: false,
                                  provisional: false,
                                  sound: true,
                                );
                                if (value) {
                                  if (settings.authorizationStatus ==
                                      AuthorizationStatus.authorized) {
                                    final pnToken = await messaging.getToken();
                                    await Clipboard.setData(ClipboardData(text: pnToken.toString()));
                                  }
                                }
                                setState(() {
                                  notifications = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTapUp: (_) {
                          setState(() {
                            buttonColor = HavkaColors.black.withValues(alpha: 0.05);
                            _clearCache();
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            buttonColor = HavkaColors.black.withValues(alpha: 0.1);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Clear cache"),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTapUp: (_) {
                          setState(() {
                            _logout();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Log out", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _clearCache() async {
    final dir = await getTemporaryDirectory();
    dir.delete(recursive: true);
  }

  Future<void> _logout() async {
    await _clearCache();
    setState(() {
      removeToken();
      final googleSignIn = GoogleSignIn(scopes: ["email", "profile"]);
      googleSignIn.signOut();
      googleSignIn.disconnect();

      context.pop();
      context.go("/login");
    });
  }
}
