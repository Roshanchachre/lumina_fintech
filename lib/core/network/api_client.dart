import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';

class ApiClient {
  final Dio dio;
  String? _authToken;

  ApiClient({Dio? customDio})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 10),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'X-Client-Platform': 'Flutter-Mobile',
                  'X-Lumina-Version': '1.0.0',
                },
              ),
            ) {
    _initializeInterceptors();
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  void _initializeInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Automatic multi-host fallback for physical devices (e.g. iPhone) and emulators
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            final requestOptions = error.requestOptions;
            final attempted = List<String>.from(
              (requestOptions.extra['attempted_urls'] as List?) ?? [],
            );
            attempted.add(dio.options.baseUrl);

            for (final candidate in ApiEndpoints.candidateBaseUrls) {
              if (!attempted.contains(candidate)) {
                try {
                  final retryOptions = Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                    responseType: requestOptions.responseType,
                    contentType: requestOptions.contentType,
                    extra: {
                      ...requestOptions.extra,
                      'attempted_urls': [...attempted, candidate],
                    },
                  );

                  final testDio = Dio(
                    BaseOptions(
                      baseUrl: candidate,
                      connectTimeout: const Duration(seconds: 4),
                      receiveTimeout: const Duration(seconds: 4),
                    ),
                  );

                  final response = await testDio.request(
                    requestOptions.path,
                    data: requestOptions.data,
                    queryParameters: requestOptions.queryParameters,
                    options: retryOptions,
                  );

                  // Successfully reached candidate! Switch active baseUrl for all subsequent requests
                  ApiEndpoints.baseUrl = candidate;
                  dio.options.baseUrl = candidate;
                  return handler.resolve(response);
                } catch (_) {
                  // Fall through to next candidate
                }
              }
            }
          }

          final mappedException = _mapDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: mappedException,
              message: mappedException.message,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  ApiException _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return NetworkException(
        url: ApiEndpoints.baseUrl,
        message: 'Unable to reach institutional banking server at ${ApiEndpoints.baseUrl}. Check network connection.',
      );
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;
      final message = (data is Map && data.containsKey('message'))
          ? data['message'].toString()
          : (data is String && data.isNotEmpty)
              ? data
              : 'Server responded with status $statusCode';

      if (statusCode == 401) {
        return UnauthorizedException(message: message);
      } else if (statusCode == 409) {
        final idempotencyKey = response.headers.value('x-idempotency-key') ?? 'UNKNOWN_KEY';
        return DuplicateTransactionException(idempotencyKey: idempotencyKey, message: message);
      } else if (statusCode == 422) {
        return InsufficientFundsException(message: message);
      } else if (statusCode != null && statusCode >= 500) {
        return ServerException(message: message);
      }

      return ApiException(message: message, statusCode: statusCode, details: data);
    }

    return ApiException(message: error.message ?? 'Unexpected network anomaly');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}
