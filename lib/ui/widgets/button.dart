import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';

class HavkaButton extends StatelessWidget {
  final Widget child;
  final String text;
  final void Function() onPressed;
  final Color color;
  final Color textColor;
  final double radius;
  final ButtonStyle? style;
  final double fontSize;

  const HavkaButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.text = "button",
    this.color = HavkaColors.green,
    this.textColor = Colors.white,
    this.radius = 8,
    this.fontSize = 16,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: HavkaColors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ).merge(style),
      onPressed: onPressed,
      child: child,
      // const Align(
      //   child:
      // )
    );
  }
  //
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(radius),
  //     child: Stack(
  //       children: <Widget>[
  //         Positioned.fill(
  //           child: Container(
  //             decoration: const BoxDecoration(
  //               color: HavkaColors.green,
  //               gradient: LinearGradient(
  //                 colors: <Color>[
  //                   Color(0xFF5BBE78),
  //                   Color(0xFF5BBE78),
  //                   Color(0xFF5BBE78),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         TextButton(
  //             style: TextButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8.0),
  //               ),
  //               alignment: Alignment.center,
  //               foregroundColor: Colors.white,
  //               textStyle: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ).merge(style),
  //             onPressed: onPressed,
  //             child: child,
  //             // const Align(
  //             //   child:
  //             // )
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

final FirebaseAuth authInstance = FirebaseAuth.instance;

class GoogleSignInButton extends StatelessWidget {
  // const GoogleSignInButton({Key? key}) : super(key: key);

  Future<void> _googleSignIn(BuildContext context) async {
    final GoogleSignIn googleSignIn =
        GoogleSignIn(scopes: ['email', 'profile']);
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      log(googleAuth.idToken!);
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        await authInstance.signInWithCredential(credential);
        final bool isAuthSuccess =
            await ApiRoutes().signInGoogle(googleAuth.idToken!);
        if (isAuthSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HavkaButton(
      child: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/icons/google.webp',
              fit: BoxFit.fill,
            ),
            Text('Continue with Google'),
          ],
        ),
      ),
      onPressed: () {
        _googleSignIn(context);
      },
    );
    // return Align(
    //   alignment: AlignmentDirectional(0, 0),
    //   child: Container(
    //     width: 230,
    //     height: 44,
    //     child: Stack(
    //       children: [
    //         Align(
    //           alignment: AlignmentDirectional(0, 0),
    //           child: HavkaButton(
    //             onPressed: () {
    //               print('Button pressed ...');
    //             },
    //             child: Row(
    //               children: [
    //                 Text('Sign in with Google'),
    //                 Image.asset(
    //                   'assets/icons/google.webp',
    //                   fit: BoxFit.contain,
    //                 ),
    //               ]
    //             )
    //             // icon: Icon(
    //             //   Icons.add,
    //             //   color: Colors.transparent,
    //             //   size: 20,
    //             // ),
    //             // options: FFButtonOptions(
    //             //   width: 230,
    //             //   height: 44,
    //             //   color: Colors.white,
    //             //   textStyle: GoogleFonts.getFont(
    //             //     'Roboto',
    //             //     color: Color(0xFF606060),
    //             //     fontSize: 17,
    //             //   ),
    //             //   elevation: 4,
    //             //   borderSide: BorderSide(
    //             //     color: Colors.transparent,
    //             //     width: 0,
    //             //   ),
    //             ),
    //           ),
    //         // ),
    //         // Align(
    //         //   alignment: AlignmentDirectional(-0.83, 0),
    //         //   child: Container(
    //         //     width: 22,
    //         //     height: 22,
    //         //     clipBehavior: Clip.antiAlias,
    //         //     decoration: BoxDecoration(
    //         //       shape: BoxShape.circle,
    //         //     ),
    //         //     child: Image.asset(
    //         //       'assets/icons/google.webp',
    //         //       fit: BoxFit.contain,
    //         //     ),
    //         //   ),
    //         // ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
