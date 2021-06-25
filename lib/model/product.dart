class Product {
  final int id;
  final String name;
  final int protein;
  final int fat;
  final int carbs;
  final int kcal;
  final int baseValue;

  Product({
    this.id,
    this.name,
    this.protein,
    this.fat,
    this.carbs,
    this.kcal,
    this.baseValue
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        protein = json['protein'],
        fat = json['fat'],
        carbs = json['carbs'],
        kcal = json['kcal'],
        baseValue = json['nutrition_per'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'kcal': kcal,
        'nutrition_per': baseValue
      };
}