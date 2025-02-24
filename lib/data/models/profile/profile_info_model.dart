import 'package:intl/intl.dart';

import '../../../domain/entities/profile/profile_info.dart';

class ProfileInfoModel {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? photo;
  int? _age;

  ProfileInfoModel({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.photo,
  });

  @override
  String toString() => this.toJson().toString();

  int? get age {
    _calculateAge();
    return _age;
  }

  void _calculateAge() {
    if (dateOfBirth == null) {
      _age = null;
      return;
    }
    DateTime now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    _age = years;
  }

  factory ProfileInfoModel.fromJson(Map<String, dynamic> json) {
    return ProfileInfoModel(
        firstName: json["first_name"] as String?,
        lastName: json["last_name"] as String?,
        dateOfBirth: DateFormat("yyyy-MM-dd").parse(json["date_of_birth"]) as DateTime?,
        gender: json["gender"] as String?,
        photo: json["photo"] as String?,
      );
  }

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "date_of_birth": DateFormat("yyyy-MM-dd").format(dateOfBirth!),
    "gender": gender,
    "photo": photo,
  };

  static ProfileInfoModel fromDomain(ProfileInfo profileInfo) {
    return ProfileInfoModel(
      firstName: profileInfo.firstName,
      lastName: profileInfo.lastName,
      dateOfBirth: profileInfo.dateOfBirth,
      gender: profileInfo.gender,
      photo: profileInfo.photo,
    );
  }

  ProfileInfo toDomain() {
    return ProfileInfo(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      photo: photo,
    );
  }
}