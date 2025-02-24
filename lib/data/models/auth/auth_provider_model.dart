import '../../../domain/entities/auth/auth_provider.dart';

class AuthProviderModel {
  final String provider;
  final String hashedPassword;

  AuthProviderModel({
    required this.provider,
    required this.hashedPassword,
  });

  factory AuthProviderModel.fromJson(Map<String, dynamic> json) {
    return AuthProviderModel(
      provider: json["provider"],
      hashedPassword: json["hashed_password"],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        "provider": provider,
        "hashed_password": hashedPassword,
      };

  static AuthProviderModel fromDomain(AuthProvider authProvider) {
    return AuthProviderModel(
      provider: authProvider.provider,
      hashedPassword: authProvider.hashedPassword,
    );
  }

  AuthProvider toDomain() {
    return AuthProvider(
      provider: provider,
      hashedPassword: hashedPassword,
    );
  }
}