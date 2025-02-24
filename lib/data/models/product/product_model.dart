import 'package:havka/data/models/product/nutrition_model.dart';
import 'package:havka/data/models/product/package_model.dart';
import 'package:havka/data/models/product/serving_model.dart';
import 'package:havka/domain/entities/product/product.dart';
import 'package:intl/intl.dart';

import 'brand_model.dart';

class ProductModel {
  final String? id;
  final String name;
  Map<String, dynamic>? brand;
  Map<String, dynamic>? nutrition;
  List<Map<String, dynamic>> serving;
  String? barcode;
  String? baseUnit;
  Map<String, dynamic>? package;
  Map<String, dynamic>? images;
  String? countryCode;
  DateTime createdAt;
  DateTime updatedAt;

  ProductModel({
    this.id,
    required this.name,
    this.brand,
    this.nutrition,
    required this.serving,
    this.barcode,
    this.baseUnit,
    this.package,
    this.images,
    this.countryCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        id: json['_id'] as String?,
        name: json['name'] as String,
        brand: json['brand'] as Map<String, dynamic>?,
        nutrition: json['nutrition'] as Map<String, dynamic>?,
        serving: (json['serving'] as List<dynamic>).map((s) => Map<String, dynamic>.from(s)).toList(),
        barcode: json['barcode'] as String?,
        baseUnit: json['base_unit'] as String?,
        package: json['package'] as Map<String, dynamic>?,
        // images: json['photos'] as Map<String, dynamic>?,
        // countryCode: json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'nutrition': nutrition,
      'serving': serving,
      'base_unit': baseUnit,
      'barcode': barcode,
      'package': package,
      'photos': images != null ? {'foody': images} : null,
      'country_code': countryCode,
      'created_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt.toUtc()),
      'updated_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(updatedAt.toUtc()),
    };
  }

  @override
  String toString() => this.toJson().toString();

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      brand: brand != null ? BrandModel.fromJson(brand!).toDomain() : null,
      nutrition: nutrition != null ? NutritionModel.fromJson(nutrition!).toDomain() : null,
      serving: serving.map((e) => ServingModel.fromJson(e).toDomain()).toList(),
      barcode: barcode,
      baseUnit: baseUnit,
      package: package != null ? PackageModel.fromJson(package!).toDomain() : null,
      countryCode: countryCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ProductModel fromDomain(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      brand: product.brand != null ? BrandModel.fromDomain(product.brand!).toJson() : null,
      nutrition: product.nutrition != null ? NutritionModel.fromDomain(product.nutrition!).toJson() : null,
      serving: product.serving.map((s) => ServingModel.fromDomain(s).toJson()).toList(),
      barcode: product.barcode,
      baseUnit: product.baseUnit,
      package: product.package != null ? PackageModel.fromDomain(product.package!).toJson() : null,
      countryCode: product.countryCode,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}