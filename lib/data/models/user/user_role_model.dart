import '../../../domain/entities/user/user_role.dart';

class UserRoleModel {
  final bool isUser;
  final bool isAdmin;

  UserRoleModel({
    required this.isUser,
    required this.isAdmin,
  });

  @override
  String toString() => this.toJson().toString();

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      isUser: json["is_user"],
      isAdmin: json["is_admin"],
    );
  }

  Map<String, dynamic> toJson() => {
    "is_user": isUser,
    "is_admin": isAdmin,
  };

  static UserRoleModel fromDomain(UserRole userRole) {
    return UserRoleModel(
      isUser: userRole.isUser,
      isAdmin: userRole.isAdmin,
    );
  }

  UserRole toDomain() {
    return UserRole(
      isUser: isUser,
      isAdmin: isAdmin,
    );
  }
}