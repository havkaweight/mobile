import '../../../domain/entities/health/health_data.dart';

class HealthDataModel {
  final DateTime date;
  final double weight;

  HealthDataModel({
    required this.date,
    required this.weight,
  });

  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    return HealthDataModel(
      date: DateTime.parse(json['dateFrom']),
      weight: json['value']['numericValue'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }

  HealthData toEntity() {
    return HealthData(
      date: date,
      weight: weight,
    );
  }
}
