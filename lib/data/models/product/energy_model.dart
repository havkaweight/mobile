import '../../../domain/entities/product/energy.dart';

class EnergyModel {
  final double? kcal;
  final double? kJ;

  EnergyModel({
    this.kcal,
    this.kJ,
  });

  @override
  String toString() => this.toJson().toString();

  factory EnergyModel.fromJson(Map<String, dynamic> json) {
    return EnergyModel(
      kcal: json['kcal'],
      kJ: json['kj'],
    );
  }

  Map<String, dynamic> toJson() => {
    'kcal': kcal,
    'kj': kJ,
  };

  Energy toDomain() {
    return Energy(
      kcal: kcal,
      kJ: kJ,
    );
  }

  static EnergyModel fromDomain(Energy energy) {
    return EnergyModel(
      kcal: energy.kcal,
      kJ: energy.kJ,
    );
  }
}