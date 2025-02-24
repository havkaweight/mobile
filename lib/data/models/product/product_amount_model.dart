import '../../../domain/entities/product/product_amount.dart';

class ProductAmountModel {
  final String unit;
  final double value;

  ProductAmountModel({
    required this.unit,
    required this.value,
  });

  @override
  String toString() => this.toJson().toString();

  factory ProductAmountModel.fromJson(Map<String, dynamic> json) {
    return ProductAmountModel(
      unit: json['unit'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
    'unit': unit,
    'value': value,
  };

  ProductAmount toDomain() {
    return ProductAmount(
      unit: unit,
      value: value,
    );
  }

  static ProductAmountModel fromDomain(ProductAmount productAmount) {
    return ProductAmountModel(
      unit: productAmount.unit,
      value: productAmount.value,
    );
  }
}