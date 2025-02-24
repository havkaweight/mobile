class Weight {
  String? unit;
  double? value;

  Weight({
    this.unit,
    this.value,
  });

  String get formattedValue {
    if (unit == null || value == null)
      return '-';
    return '${value?.toStringAsFixed(1)} $unit';
  }
}