import 'dart:io';

import 'package:health/health.dart';
import 'package:intl/intl.dart';

class UserWeightItem {
  final DateTime createdAt;
  final double value;

  UserWeightItem({
    required this.createdAt,
    required this.value,
  });

  UserWeightItem.fromJson(Map<String, dynamic> json)
    : createdAt = json["created_at"],
      value = json["value"];

  toJson() => {
    "created_at": createdAt,
    "value": value,
  };

  UserWeightItem.fromHealthDataPoint(HealthDataPoint healthDataPoint)
    : createdAt = healthDataPoint.dateTo,
      value = double.parse(healthDataPoint.value.toString());
}

class UserStatus {
  final bool? isActive;
  final bool? isSuperuser;
  final bool? isVerified;

  UserStatus({
    this.isActive,
    this.isSuperuser,
    this.isVerified,
  });

  factory UserStatus.fromJson(Map<String, dynamic> data) => UserStatus(
        isActive: data['is_active'] as bool?,
        isSuperuser: data['is_superuser'] as bool?,
        isVerified: data['is_verified'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'is_active': isActive,
        'is_superuser': isSuperuser,
        'is_verified': isVerified,
      };
}
