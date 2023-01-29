class User {
  final String? id;
  final String? email;
  final bool? isActive;
  final bool? isSuperuser;
  final bool? isVerified;

  User({
    this.id,
    this.email,
    this.isActive,
    this.isSuperuser,
    this.isVerified
  });

  factory User.fromJson(Map<String, dynamic> data) => User(
    id: data['id'] as String,
    email: data['email'] as String,
    isActive: data['is_active'] as bool,
    isSuperuser: data['is_superuser'] as bool,
    isVerified: data['is_verified'] as bool
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'is_active': isActive,
    'is_superuser': isSuperuser,
    'is_verified': isVerified
  };
}