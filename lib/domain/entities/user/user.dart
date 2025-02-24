import 'package:havka/domain/entities/user/user_role.dart';
import 'package:havka/domain/entities/user/user_status.dart';
import '../auth/auth_provider.dart';


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
}
