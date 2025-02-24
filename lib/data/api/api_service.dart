import 'package:dio/dio.dart';
import 'package:havka/domain/repositories/auth/auth_repository.dart';
import 'auth_interceptor.dart';

class ApiService {
  final Dio _dio;

  ApiService({
    required String baseUrl,
    required AuthRepository authRepository,
  }) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
    headers: {'Content-Type': 'application/json'},
  )) {
    _dio.interceptors.add(AuthInterceptor(_dio, authRepository));
  }

  Future<Response> get(
      String endpoint,
      {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
      }) async {
    try {
      return await _dio.get(
          endpoint,
          queryParameters: queryParameters,
          options: Options(headers: headers),
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> post(
    String endpoint,
    {
      Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
    }) async {
    try {
      print(endpoint);
      print(data);
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
        queryParameters: queryParameters,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> put(
      String endpoint,
      {
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
      }) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> patch(
      String endpoint,
      {
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
      }) async {
    try {
      return await _dio.patch(
          endpoint,
          queryParameters: queryParameters,
          data: data
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }


  Future<Response> delete(
      String endpoint,
      {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? data,
      }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        options: Options(headers: headers),
        queryParameters: queryParameters,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
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