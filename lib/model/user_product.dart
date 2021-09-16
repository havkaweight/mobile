class UserProduct {
  final int id;
  final int productId;
  final String productName;
  final String productBrand;
  final String userId;
  final double protein;
  final double fat;
  final double carbs;
  final double kcal;
  final double netWeightLeft;
  final String unit;

  UserProduct({
    this.id,
    this.productId,
    this.productName,
    this.productBrand,
    this.userId,
    this.protein,
    this.fat,
    this.carbs,
    this.kcal,
    this.netWeightLeft,
    this.unit
  });

  UserProduct.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        productId = json['product_id'] as int,
        productName = json['name'] as String,
        productBrand = json['brand'] as String,
        userId = json['user_id'] as String,
        protein = json['proteins'] as double,
        fat = json['fats'] as double,
        carbs = json['carbs'] as double,
        kcal = json['kcal'] as double,
        netWeightLeft = json['net_weight_left'] as double,
        unit = json['unit'] as String;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'product_id': productId,
        'name': productName,
        'brand': productBrand,
        'user_id': userId,
        'proteins': protein,
        'fats': fat,
        'carbs': carbs,
        'kcal': kcal,
        'net_weight_left': netWeightLeft,
        'unit': unit
      };

  Map<String, dynamic> idToJson() =>
      {
        'id': id
      };
}