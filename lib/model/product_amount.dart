class ProductAmount {
  final String? unit;
  double? value;

  ProductAmount({
    this.unit,
    this.value,
  });

  ProductAmount.fromJson(Map<String, dynamic> json)
      : unit = json['unit'] as String?,
        value = json['value'] == null
        ? null
        : json['value'].toDouble();

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'value': value,
      };
}
