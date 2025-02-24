import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'endpoints.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService({required String baseUrl})
      : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Future<Response> login(String username, String password) async {
    log("AuthApiService: Login with username: $username and password: $password");
    log('${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signIn}');
    try {
      final response = await _dio.post(
        '${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signIn}',
        data: {
          'email_or_username': username,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> signUp(String username, String password) async {
    try {
      final response = await _dio.post(
          '${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signUp}',
          data: {
            'email': username,
            'password': password,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.get(
          '${Endpoints.prefix}${Endpoints.userService}${Endpoints.tokenUpdate}',
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
            }
          ),
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> loginWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? auth = await account?.authentication;
    final String? idToken = auth?.idToken;
    try {
      final response = await _dio.post(
        '${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signInGoogle}',
        data: {
          'id_token': idToken,
        },
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> loginWithApple(String email) async {
    try {
      final response = await _dio.post(
        '${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signInApple}',
        data: {
          'email': email,
        },
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }

  void _handleError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          print('Error: Connection timeout');
          break;
        case DioExceptionType.badResponse:
          print('Error: ${error.response?.statusCode} - ${error.response?.statusMessage}');
          break;
        case DioExceptionType.cancel:
          print('Error: Request canceled');
          break;
        case DioExceptionType.unknown:
          print('Error: ${error.message}');
          break;
        default:
          print('Error: Unknown Dio error');
      }
    } else {
      print('Error: $error');
    }
  }
}