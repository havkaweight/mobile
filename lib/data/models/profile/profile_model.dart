import 'package:havka/data/models/profile/profile_info_model.dart';

import '../../../domain/entities/profile/profile.dart';
import 'body_stats_model.dart';

class ProfileModel {
  final String? id;
  final String userId;
  final Map<String, dynamic>? bodyStats;
  final Map<String, dynamic>? profileInfo;

  ProfileModel({
    this.id,
    required this.userId,
    this.bodyStats,
    this.profileInfo,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'],
      userId: json['user_id'],
      bodyStats: json['body_stats'],
      profileInfo: json['profile_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'body_stats': bodyStats,
      'profile_info': profileInfo,
    };
  }

  @override
  String toString() => this.toJson().toString();

  static ProfileModel fromDomain(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      bodyStats: BodyStatsModel.fromDomain(profile.bodyStats!).toJson(),
      profileInfo: ProfileInfoModel.fromDomain(profile.profileInfo!).toJson(),
    );
  }

  Profile toDomain() {
    return Profile(
      id: id,
      userId: userId,
      bodyStats: BodyStatsModel.fromJson(bodyStats!).toDomain(),
      profileInfo: ProfileInfoModel.fromJson(profileInfo!).toDomain(),
    );
  }
}