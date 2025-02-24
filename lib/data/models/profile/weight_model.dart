import '../../../domain/entities/profile/weight.dart';

class WeightModel {
  String? unit;
  double? value;

  WeightModel({
    this.unit,
    this.value,
  });

  @override
  String toString() => this.toJson().toString();

  factory WeightModel.fromJson(Map<String, dynamic> json) {
    return WeightModel(
      unit: json['unit'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
    'unit': unit,
    'value': value,
  };

  static WeightModel fromDomain(Weight height) {
    return WeightModel(
      unit: height.unit,
      value: height.value,
    );
  }

  Weight toDomain() {
    return Weight(
      unit: unit,
      value: value,
    );
  }
}