import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/utils.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;

  TokenStorage._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await storage.write(key: _accessTokenKey, value: accessToken);
      await storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      print('Error saving tokens: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: _accessTokenKey);
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: _refreshTokenKey);
    } catch (e) {
      print("Error getting refresh token: $e");
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await storage.delete(key: _accessTokenKey);
      await storage.delete(key: _refreshTokenKey);
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }
}
