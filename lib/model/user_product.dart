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
      : id = json['id'],
        productId = json['product_id'],
        productName = json['name'],
        userId = json['user_id'],
        protein = json['protein'],
        fat = json['fat'],
        carbs = json['carbs'],
        kcal = json['kcal'],
        amount = json['amount'];

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