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

  int? get age {
    if (dateOfBirth == null) {
      return null;
    }

    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;

    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }

    return age;
  }

  String? get formattedAge => '${age!.toStringAsFixed(0)} y.o.';
}