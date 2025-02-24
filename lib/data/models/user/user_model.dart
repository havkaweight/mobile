import 'package:havka/data/models/auth/auth_provider_model.dart';
import 'package:havka/data/models/user/user_role_model.dart';
import 'package:havka/data/models/user/user_status_model.dart';
import 'package:havka/domain/entities/auth/auth_provider.dart';
import 'package:havka/domain/entities/user/user_status.dart';

import '../../../domain/entities/user/user.dart';

class UserModel {
  final String id;
  final String email;
  String username;
  final List<Map<String, dynamic>> authProviders;
  final Map<String, dynamic> userRoles;
  final Map<String, dynamic> userStatuses;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.authProviders,
    required this.userRoles,
    required this.userStatuses,
  });

  @override
  String toString() => this.toJson().toString();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      email: json['email'],
      username: json['username'],
      authProviders: (json['auth_providers'] as List<dynamic>).map((s) => Map<String, dynamic>.from(s)).toList(),
      userRoles: json['roles'] as Map<String, dynamic>,
      userStatuses: json['status'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'username': username,
    'auth_providers': authProviders,
    'roles': userRoles,
    'status': userStatuses,
  };

  static UserModel fromDomain(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      authProviders: user.authProviders.map((authProvider) => AuthProviderModel.fromDomain(authProvider).toJson()).toList(),
      userRoles: UserRoleModel.fromDomain(user.userRoles).toJson(),
      userStatuses: UserStatusModel.fromDomain(user.userStatuses).toJson(),
    );
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      username: username,
      authProviders: authProviders.map((authProvider) => AuthProviderModel.fromJson(authProvider).toDomain()).toList(),
      userRoles: UserRoleModel.fromJson(userRoles).toDomain(),
      userStatuses: UserStatusModel.fromJson(userStatuses).toDomain(),
    );
  }

  @override
  bool operator == (Object other) {
    if (other is User) {
      return username == other.username;
    }
    return false;
  }
}