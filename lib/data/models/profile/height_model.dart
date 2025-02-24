import '../../../domain/entities/profile/height.dart';

class HeightModel {
  String? unit;
  double? value;

  HeightModel({
    this.unit,
    this.value,
  });

  @override
  String toString() => this.toJson().toString();

  factory HeightModel.fromJson(Map<String, dynamic> json) {
    return HeightModel(
      unit: json['unit'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
    'unit': unit,
    'value': value,
  };

  static HeightModel fromDomain(Height height) {
    return HeightModel(
      unit: height.unit,
      value: height.value,
    );
  }

  Height toDomain() {
    return Height(
      unit: unit,
      value: value,
    );
  }
}