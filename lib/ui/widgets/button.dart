import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/ui/screens/main_screen.dart';
import 'package:provider/provider.dart';

import '../../model/fridge.dart';

final FirebaseAuth authInstance = FirebaseAuth.instance;

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
}


class GoogleSignInButton extends StatelessWidget {
  final Function()? onPressed;
  GoogleSignInButton({
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return HavkaButton(
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Container(
              width: 50,
              child: Image.asset(
                "assets/icons/google.webp",
                fit: BoxFit.fitHeight,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: const Text("Continue with Google"),
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        if(onPressed != null) {
          onPressed!();
        }
      },
    );
  }
}


class AppleSignInButton extends StatelessWidget {
  final Function()? onPressed;
  AppleSignInButton({
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return HavkaButton(
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 50,
              child: Image.asset(
                "assets/icons/apple.webp",
                fit: BoxFit.fitHeight,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: const Text("Continue with Apple"),
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        if(onPressed != null) {
          onPressed!();
        }
      },
    );
  }
}
