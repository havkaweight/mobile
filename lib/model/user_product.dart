class UserProduct {
  final int id;
  final int productId;
  final String productName;
  final int userId;
  final double protein;
  final double fat;
  final double carbs;
  final double kcal;
  final double amount;

  UserProduct({
    this.id,
    this.productId,
    this.productName,
    this.userId,
    this.protein,
    this.fat,
    this.carbs,
    this.kcal,
    this.amount
  });

  UserProduct.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        productId = json['product_id'] as int,
        productName = json['name'] as String,
        userId = json['user_id'] as int,
        protein = json['protein'] as double,
        fat = json['fat'] as double,
        carbs = json['carbs'] as double,
        kcal = json['kcal'] as double,
        amount = json['amount'] as double;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'product_id': productId,
        'name': productName,
        'user_id': userId,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'kcal': kcal,
        'amount': amount
      };
}