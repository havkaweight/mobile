import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String image;

  const AppIcon({
    Key key,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double imageSize;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      imageSize = size.width * 0.20;
    } else {
      imageSize = size.height * 0.20;
    }

    return Image.asset(
      image,
      height: imageSize,
    );
  }
}