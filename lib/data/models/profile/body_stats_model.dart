import 'package:havka/data/models/profile/height_model.dart';
import 'package:havka/data/models/profile/weight_model.dart';

import '../../../domain/entities/profile/body_stats.dart';

class BodyStatsModel {
  Map<String, dynamic>? height;
  Map<String, dynamic>? weight;

  BodyStatsModel({
    this.height,
    this.weight,
  });

  @override
  String toString() => this.toJson().toString();

  factory BodyStatsModel.fromJson(Map<String, dynamic> json) {
    return BodyStatsModel(
      height: json['height'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() => {
    'height': height,
    'weight': weight,
  };

  static BodyStatsModel fromDomain(BodyStats bodyStats) {
    return BodyStatsModel(
      height: HeightModel.fromDomain(bodyStats.height!).toJson(),
      weight: WeightModel.fromDomain(bodyStats.weight!).toJson(),
    );
  }

  BodyStats toDomain() {
    return BodyStats(
      height: HeightModel.fromJson(height!).toDomain(),
      weight: WeightModel.fromJson(weight!).toDomain(),
    );
  }
}