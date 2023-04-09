import 'dart:convert';

class ProductNutrition {
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? kcal;

  const ProductNutrition({
    this.protein,
    this.fat,
    this.carbs,
    this.kcal,
  });

  ProductNutrition.fromJson(Map<dynamic, dynamic> json)
      : protein = json['protein'] as double?,
        fat = json['fat'] as double?,
        carbs = json['carbs'] as double?,
        kcal = json['kcal'] as double?;

  Map<dynamic, dynamic> toJson() => {
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'kcal': kcal,
      };
}

class Product {
  final String? id;
  final String? name;
  final String? brand;
  final ProductNutrition? nutrition;
  final double? baseValue;
  final String? barcode;
  final String? img;

  Product({
    this.id,
    this.name,
    this.brand,
    this.nutrition,
    this.baseValue,
    this.barcode,
    this.img,
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        name = json['name'] as String,
        brand = json['brand'] as String?,
        nutrition = json['nutrition'] == null
            ? null
            : ProductNutrition.fromJson(
                json['nutrition'] as Map<String, dynamic>,
              ),
        baseValue = json['net_weight'] as double?,
        barcode = json['barcode'] as String?,
        img = json['imgs'] == null
            ? null
            : json['imgs']['foody'] == null
                ? null
                : json['imgs']['foody']['original'] == null
                    ? null
                    : (json['imgs']['foody']['original'] as String)
                        .replaceAll('?', '%3F');

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'brand': brand,
        'nutrition': nutrition == null ? null : nutrition!.toJson(),
        'net_weight': baseValue,
        'barcode': barcode,
        'imgs': img,
      };

  Map<String, dynamic> productIdToJson() => {'product_id': id};
}
