import '../../../domain/entities/product/brand.dart';

class BrandModel {
  final String? name;
  final String? type;

  BrandModel({
    this.name,
    this.type,
  });

  @override
  String toString() => this.toJson().toString();

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
  };

  Brand toDomain() {
    return Brand(
      name: name,
      type: type,
    );
  }

  static BrandModel fromDomain(Brand brand) {
    return BrandModel(
      name: brand.name,
      type: brand.type,
    );
  }
}