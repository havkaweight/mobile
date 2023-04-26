class ProductAmount {
  final String unit;
  final double value;

  ProductAmount({
    required this.unit,
    required this.value,
  });

  ProductAmount.fromJson(Map<String, dynamic> json)
      : unit = json['unit'] as String,
        value = json['value'] as double;

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'value': value,
      };
}
