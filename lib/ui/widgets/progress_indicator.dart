import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HavkaProgressIndicator extends StatelessWidget {
  final Color? color;

  const HavkaProgressIndicator({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      child: Platform.isAndroid
      ? CircularProgressIndicator(
        color: Theme
            .of(context)
            .primaryColor,
      )
      : const CupertinoActivityIndicator(),
    );
  }
}
