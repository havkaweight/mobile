import 'package:havka/domain/entities/product/protein.dart';
import 'package:havka/domain/entities/product/fat.dart';
import 'package:havka/domain/entities/product/carbs.dart';
import 'package:havka/domain/entities/product/energy.dart';

class Nutrition {
  final Protein? protein;
  final Fat? fat;
  final Carbs? carbs;
  final Energy? energy;
  final String? unit;
  final double? valuePerInBaseUnit;

  const Nutrition({
    this.protein,
    this.fat,
    this.carbs,
    this.energy,
    this.unit,
    this.valuePerInBaseUnit,
  });
}