import '../../../domain/entities/product/carbs.dart';

class CarbsModel {
  final double? total;
  final double? dietaryFiber;
  final double? sugars;

  CarbsModel({
    this.total,
    this.dietaryFiber,
    this.sugars,
  });

  @override
  String toString() => this.toJson().toString();

  factory CarbsModel.fromJson(Map<String, dynamic> json) => CarbsModel(
    total: json['total'],
    dietaryFiber: json['dietary_fiber'],
    sugars: json['sugars'],
  );

  Map<String, dynamic> toJson() => {
    'total': this.total,
    'dietary_fiber': this.dietaryFiber,
    'sugars': this.sugars,
  };

  Carbs toDomain() {
    return Carbs(
      total: this.total,
      dietaryFiber: this.dietaryFiber,
      sugars: this.sugars,
    );
  }

  static CarbsModel fromDomain(Carbs carbs) {
    return CarbsModel(
      total: carbs.total,
      dietaryFiber: carbs.dietaryFiber,
      sugars: carbs.sugars,
    );
  }
}