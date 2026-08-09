import 'package:dio/dio.dart';

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.expensex.com/v1';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Endpoint paths
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String transactions = '/transactions';
  static const String categories = '/categories';
  static const String budgets = '/budgets';
  static const String accounts = '/accounts';
  static const String analytics = '/analytics';
  static const String recurringExpenses = '/recurring-expenses';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
            receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Token injection mock pattern
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
}
