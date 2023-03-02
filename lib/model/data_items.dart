import 'dart:ui';

class DataItem {
  final double value;
  final String label;
  final Color color;

  DataItem(this.value, this.label, this.color);
}

class DataPoint {
  final double dx;
  final double dy;

  DataPoint(this.dx, this.dy);
}