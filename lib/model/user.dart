class Height {
  final String? unit;
  final double? value;

  Height({
    this.unit,
    this.value,
  });

  factory Height.fromJson(Map<String, dynamic> data) => Height(
        unit: data['unit'] as String?,
        value: data['value'] as double?,
      );

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'value': value,
      };
}

class Weight {
  final String? unit;
  final double? value;

  Weight({
    this.unit,
    this.value,
  });

  factory Weight.fromJson(Map<String, dynamic> data) => Weight(
        unit: data['unit'] as String?,
        value: data['value'] as double?,
      );

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'value': value,
      };
}

class ProfileInfo {
  final String? firstName;
  final String? lastName;

  ProfileInfo({
    this.firstName,
    this.lastName,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> data) => ProfileInfo(
        firstName: data['first_name'] as String?,
        lastName: data['last_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
      };
}

class BodyStats {
  final Height? height;
  final Weight? weight;

  BodyStats({
    this.height,
    this.weight,
  });

  factory BodyStats.fromJson(Map<String, dynamic> data) => BodyStats(
        height: Height.fromJson(data['height'] as Map<String, dynamic>),
        weight: Weight.fromJson(data['weight'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
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

class User {
  final String? id;
  final String? email;
  final String? username;
  final ProfileInfo? profileInfo;
  final BodyStats? bodyStats;
  final UserStatus? userStatus;

  User({
    this.id,
    this.email,
    this.username,
    this.profileInfo,
    this.bodyStats,
    this.userStatus,
  });

  factory User.fromJson(Map<String, dynamic> data) => User(
        id: data['_id'] as String?,
        email: data['email'] as String?,
        username: data['username'] as String?,
        profileInfo: data['profile_info'] == null
            ? null
            : ProfileInfo.fromJson(
                data['profile_info'] as Map<String, dynamic>),
        bodyStats: data['body_stats'] == null
            ? null
            : BodyStats.fromJson(data['body_stats'] as Map<String, dynamic>),
        userStatus: data['status'] == null
            ? null
            : UserStatus.fromJson(data['status'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "email": email,
        "username": username,
        "profile_info": profileInfo == null ? null : profileInfo!.toJson(),
        "body_stats": bodyStats == null ? null : bodyStats!.toJson(),
        "status": userStatus == null ? null : userStatus!.toJson(),
      };
}
