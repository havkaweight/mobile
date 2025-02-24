class AuthProvider {
  final String provider;
  final String hashedPassword;

  AuthProvider({
    required this.provider,
    required this.hashedPassword,
  });
}