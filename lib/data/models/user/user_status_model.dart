import '../../../domain/entities/user/user_status.dart';

class UserStatusModel {
  final bool? isActive;
  final bool? isPremium;
  final bool? isVerified;

  UserStatusModel({
    this.isActive,
    this.isPremium,
    this.isVerified,
  });

  @override
  String toString() => this.toJson().toString();

  factory UserStatusModel.fromJson(Map<String, dynamic> json) {
    return UserStatusModel(
      isActive: json['is_active'] as bool?,
      isPremium: json['is_premium'] as bool?,
      isVerified: json['is_verified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_active': isActive,
    'is_premium': isPremium,
    'is_verified': isVerified,
  };

  static UserStatusModel fromDomain(UserStatus userStatus) {
    return UserStatusModel(
      isActive: userStatus.isActive,
      isPremium: userStatus.isPremium,
      isVerified: userStatus.isVerified,
    );
  }

  UserStatus toDomain() {
    return UserStatus(
      isActive: isActive!,
      isPremium: isPremium!,
      isVerified: isVerified!,
    );
  }
}