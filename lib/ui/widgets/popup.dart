import 'package:flutter/cupertino.dart';
import 'package:health_tracker/constants/colors.dart';

class Popup extends StatelessWidget {
  final String text;

  const Popup({
    Key key,
    this.text
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 70, left: 30, right: 30),
        decoration: BoxDecoration(
          color: HavkaColors.bone,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
            child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
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
    barrierColor: null, //Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(seconds: 1),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop(true);
      });
      return Popup(text: text);
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(anim1),
        child: child,
      );
    },
  );
}