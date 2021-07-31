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
    this.netWeightLeft
  });

  UserProduct.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        productId = json['product_id'] as int,
        productName = json['name'] as String,
        productBrand = json['brand'] as String,
        userId = json['user_id'] as String,
        protein = json['protein'] as double,
        fat = json['fat'] as double,
        carbs = json['carbs'] as double,
        kcal = json['kcal'] as double,
        netWeightLeft = json['new_weight_left'] as double;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'product_id': productId,
        'name': productName,
        'brand': productBrand,
        'user_id': userId,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'kcal': kcal,
        'new_weight_left': netWeightLeft
      };

  Map<String, dynamic> idToJson() =>
      {
        'id': id
      };
}