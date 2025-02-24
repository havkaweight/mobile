abstract class AuthRepository {
  Future<void> login(String username, String password);
  Future<void> loginWithGoogle();
  Future<void> loginWithApple(String appleToken);
  Future<void> logout();
  Future<void> signUp(String username, String password);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> refreshToken();
}