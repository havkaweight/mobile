class User {
  final String id;
  final String email;
  final bool isActive, isSuperuser, isVerified;

  User({
    this.id,
    this.email,
    this.isActive,
    this.isSuperuser,
    this.isVerified
  });

  factory User.fromJson(Map<String, dynamic> data) => User(
    id: data['id'],
    email: data['email'],
    isActive: data['is_active'],
    isSuperuser: data['is_superuser'],
    isVerified: data['is_verified']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'is_active': isActive,
    'is_superuser': isSuperuser,
    'is_verified': isVerified
  };
}