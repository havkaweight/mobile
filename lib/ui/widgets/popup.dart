import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class Popup extends StatelessWidget {
  final String? text;

  const Popup({
    Key? key,
    this.text
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(top: 40, left: 30, right: 30),
        decoration: BoxDecoration(
          color: HavkaColors.bone[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Text(
                text!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    color: HavkaColors.green,
                    decoration: TextDecoration.none
                )
            )),
      ),
    );
  }
}

Future showPopUp(BuildContext context, String text) {
  return showGeneralDialog(
    barrierLabel: "Label",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(seconds: 1),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      Future.delayed(const Duration(seconds: 3), () {
        // To safely refer to a widget's ancestor in its dispose() method,
        // save a reference to the ancestor by calling
        // dependOnInheritedWidgetOfExactType() in the
        // widget's didChangeDependencies() method.
        Navigator.of(context).pop(true);
      });
      return Popup(text: text);
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: Offset.zero).animate(anim1),
        child: child,
      );
    },
  );
}
