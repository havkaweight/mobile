import 'package:havka/data/models/product/energy_model.dart';
import 'package:havka/domain/entities/product/nutrition.dart';
import 'protein_model.dart';
import 'carbs_model.dart';
import 'fat_model.dart';

class NutritionModel {
  final Map<String, dynamic> protein;
  final Map<String, dynamic> fat;
  final Map<String, dynamic> carbs;
  final Map<String, dynamic> energy;
  final double? valuePerInBaseUnit;

  NutritionModel({
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.energy,
    this.valuePerInBaseUnit,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      protein: json['protein'],
      fat: json['fat'],
      carbs: json['carbs'],
      energy: json['energy'],
      valuePerInBaseUnit: json['value_per_in_base_unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'energy': energy,
      'value_per_in_base_unit': valuePerInBaseUnit,
    };
  }

  static NutritionModel fromDomain(Nutrition nutrition) {
    return NutritionModel(
      protein: ProteinModel.fromDomain(nutrition.protein!).toJson(),
      fat: FatModel.fromDomain(nutrition.fat!).toJson(),
      carbs: CarbsModel.fromDomain(nutrition.carbs!).toJson(),
      energy: EnergyModel.fromDomain(nutrition.energy!).toJson(),
      valuePerInBaseUnit: nutrition.valuePerInBaseUnit,
    );
  }

  Nutrition toDomain() {
    return Nutrition(
      protein: ProteinModel.fromJson(protein).toDomain(),
      fat: FatModel.fromJson(fat).toDomain(),
      carbs: CarbsModel.fromJson(carbs).toDomain(),
      energy: EnergyModel.fromJson(energy).toDomain(),
      valuePerInBaseUnit: valuePerInBaseUnit,
    );
  }
}