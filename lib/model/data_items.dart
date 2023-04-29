import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataItem {
  late double value;
  final String label;
  final Color color;

  DataItem(this.value, this.label, this.color);
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
  final IconData icon;

  PFCDataItem(this.value, this.label, this.color, this.icon);
}
