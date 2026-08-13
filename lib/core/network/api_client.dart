import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exception.dart';

abstract class AuthTokenProvider {
  Future<String?> getAccessToken();
}

class ApiConfig {
  final String baseUrl;
  final String apiVersion;
  final String environment; // development, staging, production

  const ApiConfig({
    required this.baseUrl,
    required this.apiVersion,
    required this.environment,
  });

  String get fullUrl => '$baseUrl/$apiVersion';
}

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return const ApiConfig(
    baseUrl: 'https://api.expensex.com',
    apiVersion: 'v1',
    environment: 'development',
  );
});

class ApiClient {
  final Dio _dio;
  final AuthTokenProvider? _tokenProvider;

  ApiClient(ApiConfig config, {AuthTokenProvider? tokenProvider})
      : _tokenProvider = tokenProvider,
        _dio = Dio(
          BaseOptions(
            baseUrl: config.fullUrl,
            connectTimeout: const Duration(milliseconds: 15000),
            receiveTimeout: const Duration(milliseconds: 15000),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_tokenProvider != null) {
            final token = await _tokenProvider!.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) async {
    try {
      return await _dio.patch<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('Connection timed out. Please try again.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection. Please check your network.');
    }

    final resp = error.response;
    if (resp != null) {
      final code = resp.statusCode;
      final data = resp.data;
      final msg = (data is Map && data['message'] != null) ? data['message'].toString() : 'Server communication failed.';

      switch (code) {
        case 401:
          return UnauthorizedException(msg);
        case 403:
          return ForbiddenException(msg);
        case 404:
          return NotFoundException(msg);
        case 422:
          final validationErrors = (data is Map && data['errors'] is Map)
              ? Map<String, dynamic>.from(data['errors'])
              : null;
          return ValidationException(msg, errors: validationErrors);
        case 500:
        default:
          return ServerException(msg, statusCode: code);
      }
    }

    return ApiException(error.message ?? 'An unknown error occurred.');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  return ApiClient(config);
});
