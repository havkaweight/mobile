import 'dart:convert';

class UserRole {
  final bool isUser;
  final bool isAdmin;

  UserRole({
    required this.isUser,
    required this.isAdmin,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
    isUser: json["is_user"],
    isAdmin: json["is_admin"],
  );

  Map<String, dynamic> toJson() => {
    "is_user": isUser,
    "is_admin": isAdmin,
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


class AuthProvider {
  final String provider;
  final String hashedPassword;

  AuthProvider({
    required this.provider,
    required this.hashedPassword,
  });

  factory AuthProvider.fromJson(Map<String, dynamic> json) => AuthProvider(
    provider: json["provider"],
    hashedPassword: json["hashed_password"],
  );

  Map<String, dynamic> toJson() => {
    "provider": provider,
    "hashed_password": hashedPassword,
  };
}


class User {
  final String id;
  final String email;
  String username;
  final List<AuthProvider> authProviders;
  final UserRole userRoles;
  final UserStatus userStatuses;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.authProviders,
    required this.userRoles,
    required this.userStatuses,
  });

  @override
  toString() => toJson().toString();

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    email: json["email"],
    username: json["username"],
    authProviders: (json["auth_providers"] as Iterable).map((e) => AuthProvider.fromJson(e)).toList(),
    userRoles: UserRole.fromJson(json["roles"]),
    userStatuses: UserStatus.fromJson(json["status"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "username": username,
    "auth_providers": authProviders.map((e) => e.toJson()).toList(),
    "roles": userRoles.toJson(),
    "status": userStatuses.toJson(),
  };

  @override
  bool operator == (Object other) {
    if (other is User) {
      return username == other.username;
    }
    return false;
  }
}
