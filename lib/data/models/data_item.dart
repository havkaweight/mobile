import 'dart:ui';
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
        color = Color.fromRGBO(100, 100 , 100,
          // int.parse(json['color']['r']),
          // int.parse(json['color']['g']),
          // int.parse(json['color']['b']),
          1,
        );

  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    'date': DateFormat("yyyy-MM-ddTHH:mm:ss").format(date.toUtc()),
    'color': {
      'r': color.r,
      'g': color.g,
      'b': color.b,
    },
  };
}