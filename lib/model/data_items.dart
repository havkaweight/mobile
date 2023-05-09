import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataItem {
  late double value;
  final String label;
  final Color color;

  DataItem(this.value, this.label, this.color);

  DataItem.fromJson(Map<String, dynamic> json)
      : value = json['value'] as double,
        label = json['label'] as String,
        color = Color.fromRGBO(
          json['color']['r'] as int,
          json['color']['g'] as int,
          json['color']['b'] as int,
          1,
        );

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        'color': {
          'r': color.red,
          'g': color.green,
          'b': color.blue,
        },
      };
}

class DataPoint {
  final double dx;
  final double dy;

  DataPoint(this.dx, this.dy);
}

class PFCDataItem {
  final double value;
  final String label;
  final Color color;
  final IconData? icon;
  double radius;

  PFCDataItem({
    required this.value,
    required this.label,
    required this.color,
    this.icon,
    this.radius = 1,
  });
}
