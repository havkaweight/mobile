import 'package:dio/dio.dart';
import 'package:havka/domain/repositories/auth/auth_repository.dart';
import '../../utils/get_user_id_from_token.dart';

class UnauthorizedException implements Exception {}

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthRepository _authRepository;
  bool _isRefreshing = false;
  List<void Function()> _retryQueue = [];

  AuthInterceptor(this._dio, this._authRepository);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _authRepository.getAccessToken();
    final userId = await getUserIdFromToken(accessToken);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    if (userId != null) {
      options.queryParameters['user_id'] = userId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      if (_isRefreshing) {
        _retryQueue.add(() async {
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
        });
        return;
      }

      _isRefreshing = true;
      try {
        await _authRepository.refreshToken();

        final newAccessToken = await _authRepository.getAccessToken();
        _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
        _isRefreshing = false;

        for (var retry in _retryQueue) {
          retry();
        }
        _retryQueue.clear();

        final response = await _dio.fetch(_setAuthHeader(err.requestOptions, newAccessToken));
        return handler.resolve(response);
      } catch (e) {
        _isRefreshing = false;

        await _authRepository.logout();

        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          type: DioExceptionType.unknown,
          error: UnauthorizedException(),
        ));
      }
    }

    handler.next(err);
  }

  RequestOptions _setAuthHeader(RequestOptions requestOptions, String? newToken) {
    if (newToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }
    return requestOptions;
  }
}
