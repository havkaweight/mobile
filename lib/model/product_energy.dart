class ProductEnergy {
  final String unit;
  final double value;

  ProductEnergy({
    required this.unit,
    required this.value,
  });

  ProductEnergy.fromJson(Map<String, dynamic> json)
      : unit = json['unit'] as String,
        value = json['value'] as double;

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'value': value,
      };
}
