import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';


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
    Key? key,
    required this.child,
    required this.onPressed,
    this.text = "button",
    this.color = HavkaColors.green,
    this.textColor = Colors.white,
    this.radius = 8,
    this.fontSize = 16,
    this.style,
  }) : super(key: key);


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