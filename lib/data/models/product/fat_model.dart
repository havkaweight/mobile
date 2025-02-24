import '../../../domain/entities/product/fat.dart';

class FatModel {
  final double? total;
  final double? saturated;
  final double? monounsaturated;
  final double? polyunsaturated;
  final double? trans;

  FatModel({
    this.total,
    this.saturated,
    this.monounsaturated,
    this.polyunsaturated,
    this.trans,
  });

  @override
  String toString() => this.toJson().toString();

  factory FatModel.fromJson(Map<String, dynamic> json) => FatModel(
    total: json['total'],
    saturated: json['saturated'],
    monounsaturated: json['monounsaturated'],
    polyunsaturated: json['polyunsaturated'],
    trans: json['trans'],
  );

  Map<String, dynamic> toJson() => {
    'total': this.total,
    'saturated': this.saturated,
    'monounsaturated': this.monounsaturated,
    'polyunsaturated': this.polyunsaturated,
    'trans': this.trans,
  };

  Fat toDomain() {
    return Fat(
      total: this.total,
      saturated: this.saturated,
      monounsaturated: this.monounsaturated,
      polyunsaturated: this.polyunsaturated,
      trans: this.trans,
    );
  }

  static FatModel fromDomain(Fat fat) {
    return FatModel(
      total: fat.total,
      saturated: fat.saturated,
      monounsaturated: fat.monounsaturated,
      polyunsaturated: fat.polyunsaturated,
      trans: fat.trans,
    );
  }
}