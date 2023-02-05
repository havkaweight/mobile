class Product {
  final int? id;
  final String? name;
  final String? brand;
  final double? protein;
  final double? fat;
  final double? carbs;
  final double? kcal;
  final double? baseValue;
  final String? barcode;
  final String? img;

  Product({
    this.id,
    this.name,
    this.brand,
    this.protein,
    this.fat,
    this.carbs,
    this.kcal,
    this.baseValue,
    this.barcode,
    this.img,
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as int?,
        name = json['name'] as String,
        brand = json['brand'] as String?,
        protein = json['proteins'] as double?,
        fat = json['fats'] as double?,
        carbs = json['carbs'] as double?,
        kcal = json['kcal'] as double?,
        baseValue = json['net_weight'] as double?,
        barcode = json['barcode'] as String?,
        img = json['imgs']['original'] as String?;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'brand': brand,
        'proteins': protein,
        'fats': fat,
        'carbs': carbs,
        'kcal': kcal,
        'net_weight': baseValue,
        'barcode': barcode,
        'img': img,
      };

  Map<String, dynamic> productIdToJson() =>
      {
        'product_id': id
      };
}