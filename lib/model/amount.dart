class Amount {
  final String unit;
  final double value;

  Amount({
    required this.unit,
    required this.value,
  });

  Amount.fromJson(Map<String, dynamic> json)
      : unit = json['unit'] as String,
        value = json['value'] as double;

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'value': value,
      };
}
