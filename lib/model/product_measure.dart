class ProductMeasure {
  final String unit;
  final double value;

  ProductMeasure({
    required this.unit,
    required this.value,
  });

  ProductMeasure.fromJson(Map<String, dynamic> json)
      : unit = json['unit'] as String,
        value = json['value'] as double;

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'value': value,
      };
}
