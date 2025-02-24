import '../../../domain/entities/product/package.dart';

class PackageModel {
  final String? unit;
  final double? value;

  PackageModel({
    this.unit,
    this.value,
  });

  @override
  String toString() => this.toJson().toString();

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
    unit: json['unit'],
    value: json['value'],
  );

  Map<String, dynamic> toJson() => {
    'unit': unit,
    'value': value,
  };

  static PackageModel fromDomain(Package package) {
    return PackageModel(
      unit: package.unit,
      value: package.value,
    );
  }

  Package toDomain() {
    return Package(
      unit: unit,
      value: value,
    );
  }
}