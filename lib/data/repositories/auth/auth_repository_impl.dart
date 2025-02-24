import 'dart:developer';

import '../../../domain/repositories/auth/auth_repository.dart';
import '../../api/auth_api_service.dart';
import '../../api/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({required authApiService, required this.tokenStorage}) : _authApiService = authApiService;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> login(String username, String password) async {
    log("AuthRepositoryImpl: Login");
    final response = await _authApiService.login(username, password);
    log("AuthRepositoryImpl: Login response: ${response.data}");
    final accessToken = response.data[_accessTokenKey];
    final refreshToken = response.data[_refreshTokenKey];
    await tokenStorage.saveTokens('${accessToken}s', refreshToken);
  }

  @override
  Future<String?> getAccessToken() async => await tokenStorage.getAccessToken();

  @override
  Future<String?> getRefreshToken() async => await tokenStorage.getRefreshToken();


  @override
  Future<void> loginWithGoogle() async {
    final response = await _authApiService.loginWithGoogle();
    final accessToken = response.data[_accessTokenKey];
    final refreshToken = response.data[_refreshTokenKey];
    await tokenStorage.saveTokens(accessToken, refreshToken);
  }

  @override
  Future<void> loginWithApple(String email) async {
    final response = await _authApiService.loginWithApple(email);
    final accessToken = response.data[_accessTokenKey];
    final refreshToken = response.data[_refreshTokenKey];
    await tokenStorage.saveTokens(accessToken, refreshToken);
  }

  @override
  Future<void> signUp(String username, String password) async {
    final response = await _authApiService.signUp(username, password);
    final accessToken = response.data[_accessTokenKey];
    final refreshToken = response.data[_refreshTokenKey];
    await tokenStorage.saveTokens(accessToken, refreshToken);
    await login(username, password);
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) throw Exception("No refresh token");
    final response = await _authApiService.refreshToken(refreshToken);
    final newAccessToken = response.data[_accessTokenKey];
    final newRefreshToken = response.data[_refreshTokenKey];
    await tokenStorage.saveTokens(newAccessToken, newRefreshToken);
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }
}
