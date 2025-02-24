class Height {
  String? unit;
  double? value;

  Height({
    this.unit,
    this.value,
  });

  String get formattedValue {
    if (unit == null || value == null)
      return '-';
    return '${value?.toStringAsFixed(0)} $unit';
  }
}