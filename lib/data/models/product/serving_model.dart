import '../../../domain/entities/product/serving.dart';

class ServingModel {
  final String name;
  final double valueInBaseUnit;

  ServingModel({
    required this.name,
    required this.valueInBaseUnit,
  });

  @override
  String toString() => this.toJson().toString();

  factory ServingModel.fromJson(Map<String, dynamic> json) {
    return ServingModel(
      name: json['name'],
      valueInBaseUnit: json['value_in_base_unit'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value_in_base_unit': valueInBaseUnit,
  };

  Serving toDomain() {
    return Serving(
      name: name,
      valueInBaseUnit: valueInBaseUnit,
    );
  }

  static ServingModel fromDomain(Serving serving) {
    return ServingModel(
      name: serving.name,
      valueInBaseUnit: serving.valueInBaseUnit,
    );
  }
}