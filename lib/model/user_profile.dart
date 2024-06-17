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

class Height {
  String? unit;
  double? value;

  Height({
    this.unit,
    this.value,
  });

  @override
  bool operator == (Object other) {
    if(other is Height) {
      return unit == other.unit
          && value == other.value;
    }
    return false;
  }

  factory Height.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "unit": String? _,
        "value": double? _,
      }
      => Height(
        unit: json["unit"],
        value: json["value"],
      ),
    _ => throw const FormatException("Failed to parse height")
    };
  }

  Map<String, dynamic> toJson() => {
        "unit": unit ?? null,
        "value": value ?? null,
      };
}

class Weight {
  String? unit;
  double? value;

  Weight({
    this.unit,
    this.value,
  });

  @override
  bool operator == (Object other) {
    if(other is Weight) {
      return unit == other.unit
          && value == other.value;
    }
    return false;
  }

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
        unit: json["unit"] ?? null,
        value: json["value"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "unit": unit ?? null,
        "value": value ?? null,
      };
}

class ProfileInfo {
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? gender;
  String? photo;

  ProfileInfo({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.photo,
  });

  @override
  bool operator == (Object other) {
    if(other is ProfileInfo) {
      return firstName == other.firstName
          && lastName == other.lastName
          && dateOfBirth == other.dateOfBirth
          && gender == other.gender
          && photo == other.photo;
    }
    return false;
  }

  int? get age {
    return dateOfBirth == null
        ? null
        : DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
  }

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "first_name": String? _,
        "last_name": String? _,
        "date_of_birth": String? _,
        "gender": String? _,
        "photo": String? _,
      }
      => ProfileInfo(
          firstName: json["first_name"] as String?,
          lastName: json["last_name"] as String?,
          dateOfBirth: DateFormat("yyyy-MM-dd").parse(json["date_of_birth"]) as DateTime?,
          gender: json["gender"] as String?,
          photo: json["photo"] as String?,
        ),
      _ => throw const FormatException("Failed to parse profile info"),
    };
  }

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "date_of_birth": DateFormat("yyyy-MM-dd").format(dateOfBirth!),
    "gender": gender,
    "photo": photo,
  };
}

class BodyStats {
  Height? height;
  Weight? weight;

  BodyStats({
    this.height,
    this.weight,
  });

  @override
  bool operator == (Object other) {
    if(other is BodyStats) {
      return height == other.height
          && weight == other.weight;
    }
    return false;
  }

  factory BodyStats.fromJson(Map<String, dynamic> json) => BodyStats(
        height: json.containsKey("height") && json["height"] != null ? Height.fromJson(json["height"]) : null,
        weight: json.containsKey("weight") && json["weight"] != null ? Weight.fromJson(json["weight"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "height": height == null ? null : height!.toJson(),
        "weight": weight == null ? null : weight!.toJson(),
      };
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

class UserProfile {
  final String id;
  ProfileInfo profileInfo;
  BodyStats bodyStats;

  UserProfile({
    required this.id,
    required this.profileInfo,
    required this.bodyStats,
  });

  int? get age {
    return profileInfo.dateOfBirth == null
    ? null
    : DateTime.now().difference(profileInfo.dateOfBirth!).inDays ~/ 365;
  }

  double? get dailyIntake {
   return bodyStats.weight == null || bodyStats.height == null || bodyStats.height?.value == null
     ? null
     : switch(profileInfo.gender) {
       "male" => bodyStats.weight!.value! * 10.0 + bodyStats.height!.value! * 6.25 + age! * 5.0 + 5.0,
       "female" => bodyStats.weight!.value! * 10.0 + bodyStats.height!.value! * 6.25 + age! * 5.0 - 161.0,
       _ => bodyStats.weight!.value! * 10.0 + bodyStats.height!.value! * 6.25 + age! * 5.0 - 161.0,
     };
  }

  @override
  toString() => toJson().toString();

  @override
  bool operator == (Object other) {
    if(other is UserProfile) {
      return profileInfo == other.profileInfo
          && bodyStats == other.bodyStats;
    }
    return false;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "_id": String _,
        "profile_info": Map<String, dynamic> _,
        "body_stats": Map<String, dynamic> _,
      } =>
        UserProfile(
          id: json["_id"],
          profileInfo: ProfileInfo.fromJson(
             json["profile_info"] as Map<String, dynamic>
          ),
          bodyStats: BodyStats.fromJson(
              json["body_stats"] as Map<String, dynamic>
          ),
        ),
      _ => throw const FormatException('Failed to parse user profile'),
    };
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "profile_info": profileInfo.toJson(),
    "body_stats": bodyStats.toJson(),
  };
}
