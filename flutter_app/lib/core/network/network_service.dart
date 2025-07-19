import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late Dio _dio;
  String? _authToken;

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token to headers if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          
          // Log request
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          print('DATA: ${options.data}');
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('DATA: ${response.data}');
          
          handler.next(response);
        },
        onError: (error, handler) {
          // Log error
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('MESSAGE: ${error.message}');
          
          handler.next(error);
        },
      ),
    );

    // Add retry interceptor for network failures
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            // Retry logic can be added here
            print('Network error, consider retrying...');
          }
          
          handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          type: NetworkExceptionType.timeout,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? 'An error occurred';
        
        if (statusCode == 401) {
          return NetworkException(
            message: 'Unauthorized. Please login again.',
            type: NetworkExceptionType.unauthorized,
          );
        } else if (statusCode == 403) {
          return NetworkException(
            message: 'Forbidden. You don\'t have permission.',
            type: NetworkExceptionType.forbidden,
          );
        } else if (statusCode == 404) {
          return NetworkException(
            message: 'Resource not found.',
            type: NetworkExceptionType.notFound,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return NetworkException(
            message: 'Server error. Please try again later.',
            type: NetworkExceptionType.serverError,
          );
        }
        
        return NetworkException(
          message: message,
          type: NetworkExceptionType.badRequest,
        );
      
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled.',
          type: NetworkExceptionType.cancelled,
        );
      
      default:
        return NetworkException(
          message: 'Network error. Please check your internet connection.',
          type: NetworkExceptionType.unknown,
        );
    }
  }
}

enum NetworkExceptionType {
  timeout,
  unauthorized,
  forbidden,
  notFound,
  badRequest,
  serverError,
  cancelled,
  unknown,
}

class NetworkException implements Exception {
  final String message;
  final NetworkExceptionType type;

  NetworkException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => message;
}