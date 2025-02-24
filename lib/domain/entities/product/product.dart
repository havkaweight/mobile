import 'brand.dart';
import 'nutrition.dart';
import 'package.dart';
import 'serving.dart';
import 'product_image.dart';

class Product {
  final String? id;
  final String name;
  Brand? brand;
  Nutrition? nutrition;
  List<Serving> serving;
  String? barcode;
  String? baseUnit;
  Package? package;
  ProductImage? images;
  String? countryCode;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
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
}
