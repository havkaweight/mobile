import 'package:flutter/material.dart';

class PFCDataItem {
  double value;
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

  factory PFCDataItem.fromJson(Map<String, dynamic> json) {
    return PFCDataItem(
      value: json["value"] as double,
      label: json["label"] as String,
      color: Color.fromRGBO(
        json["color"]["r"] as int,
        json["color"]["g"] as int,
        json["color"]["b"] as int,
        1,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "value": value,
      "label": label,
      "color": {
        "r": color.r,
        "g": color.g,
        "b": color.b,
      }
    };
  }

  @override
  String toString() => this.toJson().toString();
}
