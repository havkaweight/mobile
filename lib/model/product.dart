import 'dart:convert';

import 'package:health_tracker/model/product_energy.dart';
import 'package:health_tracker/model/product_measure.dart';

class ProductNutrition {
  final ProductMeasure? productMeasure;
  final double? protein;
  final double? fat;
  final double? carbs;
  final List<ProductEnergy>? energy;

  const ProductNutrition({
    this.productMeasure,
    this.protein,
    this.fat,
    this.carbs,
    this.energy,
  });

  ProductNutrition.fromJson(Map<dynamic, dynamic> json)
      : productMeasure = json['measure'] == null
            ? null
            : ProductMeasure.fromJson(json['measure'] as Map<String, dynamic>),
        protein = json['protein'] as double?,
        fat = json['fats'] as double?,
        carbs = json['carbs'] as double?,
        energy = json['energy'] == null
            ? null
            : [
                for (Map<String, dynamic> el in json['energy'])
                  ProductEnergy.fromJson(el)
              ];

  Map<dynamic, dynamic> toJson() => {
        'measure': productMeasure == null ? null : productMeasure!.toJson(),
        'protein': protein,
        'fats': fat,
        'carbs': carbs,
        'energy': energy == null
            ? null
            : [for (ProductEnergy el in energy!) el.toJson()],
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
            : json['nutrition']['per 100g'] == null
                ? null
                : ProductNutrition.fromJson(
                    json['nutrition']['per 100g'] as Map<String, dynamic>,
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
        if (id != null) '_id': id,
        'name': name,
        'brand': brand,
        'nutrition': nutrition == null
            ? null
            : {
                'per 100g': nutrition!.toJson(),
              },
        'net_weight': baseValue,
        'barcode': barcode,
        'imgs': img == null
            ? null
            : {
                'foody': {'original': img}
              },
      };

  Map<String, dynamic> productIdToJson() => {'product_id': id};
}
