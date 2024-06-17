import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataItem {
  late double value;
  final String label;
  final DateTime date;
  final Color color;

  DataItem(
    this.value,
    this.label,
    this.date,
    this.color,
  );

  @override
  toString() {
    return toJson().toString();
  }

  DataItem.fromJson(Map<String, dynamic> json)
      : value = json['value'] as double,
        label = json['label'] as String,
        date = DateFormat("yyyy-MM-ddTHH:mm:ss")
            .parse(
          json['date'] as String,
          true,
        ).toLocal(),
        color = Color.fromRGBO(
          json['color']['r'] as int,
          json['color']['g'] as int,
          json['color']['b'] as int,
          1,
        );

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        'date': DateFormat("yyyy-MM-ddTHH:mm:ss").format(date.toUtc()),
        'color': {
          'r': color.red,
          'g': color.green,
          'b': color.blue,
        },
      };
}

class DataPoint {
  DateTime dx;
  double dy;

  DataPoint(this.dx, this.dy);

  @override
  String toString() {
    return "DataPoint(dx: $dx, dy: $dy)";
  }

  @override
  bool operator == (Object other) {
    if(other is DataPoint) {
      return dx.millisecondsSinceEpoch == other.dx.millisecondsSinceEpoch &&
          dy == other.dy;
    }
    return false;
  }

  DataPoint.fromJson(Map<String, dynamic> json)
  : dx = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json["dx"]),
    dy = json["dy"];


  toJson() => {
    "dx": DateFormat("yyyy-MM-ddTHH:mm:ss").format(dx),
    "dy": dy,
  };
}

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

  @override
  toString() {
    return value.toString();
  }
}
