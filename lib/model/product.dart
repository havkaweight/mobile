class Product {
  final int id;
  final String name;
  final String brand;
  final double protein;
  final double fat;
  final double carbs;
  final double kcal;
  final double baseValue;

  Product({
    this.id,
    this.name,
    this.brand,
    this.protein,
    this.fat,
    this.carbs,
    this.kcal,
    this.baseValue
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        brand = json['brand'] as String,
        protein = json['protein'] as double,
        fat = json['fat'] as double,


        carbs = json['carbs'] as double,
        kcal = json['kcal'] as double,
        baseValue = json['nutrition_per'] as double;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'brand': brand,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'kcal': kcal,
        'nutrition_per': baseValue
      };

  Map<String, dynamic> productIdToJson() =>
      {
        'product_id': id
      };
}