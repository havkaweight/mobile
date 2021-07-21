import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HavkaProgressIndicator extends StatelessWidget {
  final Color color;

  const HavkaProgressIndicator({
    Key key,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
      );
    }
    return const CupertinoActivityIndicator();
  }

}