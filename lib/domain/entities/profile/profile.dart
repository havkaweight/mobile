import 'package:havka/domain/entities/profile/profile_info.dart';

import 'body_stats.dart';

class Profile {
  final String? id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final BodyStats? bodyStats;
  final ProfileInfo? profileInfo;

  Profile({
    this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.bodyStats,
    this.profileInfo,
  });

  int get dailyIntakeGoal {
    return (
        bodyStats!.weight!.value! * 10.0
        + bodyStats!.height!.value! * 6.25
        + profileInfo!.age! * 5.0
        + 5.0
    ).toInt();
  }
}