import 'package:dio/dio.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/config/env/env.dart';
import 'package:granio_flutter/core/helpers/constants.dart';
import 'package:granio_flutter/core/local_storage/secure_storage/i_secure_local_storage.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/core/rest_client/dio/interceptors/auth_interceptor.dart';
import 'package:granio_flutter/core/rest_client/rest_client.dart';
import 'package:granio_flutter/core/rest_client/rest_client_exception.dart';
import 'package:granio_flutter/core/rest_client/rest_client_response.dart';

class DioRestClient implements RestClient {
  final Dio _dio;

  /// Flag desta instância. `auth()`/`unauth()` criam instâncias novas que
  /// compartilham o mesmo [Dio] — nada de estado global mutável, então duas
  /// requisições simultâneas (uma pública, outra autenticada) não se misturam.
  final bool _authRequired;

  DioRestClient._(this._dio, this._authRequired);

  factory DioRestClient({
    required Logger log,
    required ISecureLocalStorage secureLocalStorage,
    required AuthStore authStore,
    BaseOptions? baseOptions,
  }) {
    final options = baseOptions ?? defaultOptions();
    final dio = Dio(options)
      ..interceptors.add(
        AuthInterceptor(
          secureLocalStorage: secureLocalStorage,
          authStore: authStore,
          log: log,
          // Sem interceptors: usado no refresh, evita recursão.
          refreshDio: Dio(options),
        ),
      );
    return DioRestClient._(dio, false);
  }

  static BaseOptions defaultOptions() {
    final baseUrl = Env.i[Constants.ENV_BASE_URL_KEY] ?? '';
    int timeout(String key) => int.tryParse(Env.i[key]?.trim() ?? '') ?? 15000;

    return BaseOptions(
      // Barra no fim + paths sem barra no começo = junção previsível.
      baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
      connectTimeout: Duration(
        milliseconds: timeout(Constants.ENV_REST_CLIENT_CONNECT_TIMEOUT_KEY),
      ),
      receiveTimeout: Duration(
        milliseconds: timeout(Constants.ENV_REST_CLIENT_RECEIVE_TIMEOUT_KEY),
      ),
      contentType: Headers.jsonContentType,
    );
  }

  @override
  DioRestClient auth() => DioRestClient._(_dio, true);

  @override
  DioRestClient unauth() => DioRestClient._(_dio, false);

  Options _options(Map<String, dynamic>? headers) => Options(
        headers: headers,
        extra: {Constants.REST_CLIENT_AUTH_REQUIRED_KEY: _authRequired},
      );

  @override
  Future<RestClientResponse<T>> get<T>(String path,
          {data,
          Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? headers}) =>
      _send(() => _dio.get(path,
          data: data,
          queryParameters: queryParameters,
          options: _options(headers)));

  @override
  Future<RestClientResponse<T>> post<T>(String path,
          {data,
          Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? headers}) =>
      _send(() => _dio.post(path,
          data: data,
          queryParameters: queryParameters,
          options: _options(headers)));

  @override
  Future<RestClientResponse<T>> put<T>(String path,
          {data,
          Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? headers}) =>
      _send(() => _dio.put(path,
          data: data,
          queryParameters: queryParameters,
          options: _options(headers)));

  @override
  Future<RestClientResponse<T>> patch<T>(String path,
          {data,
          Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? headers}) =>
      _send(() => _dio.patch(path,
          data: data,
          queryParameters: queryParameters,
          options: _options(headers)));

  @override
  Future<RestClientResponse<T>> delete<T>(String path,
          {data,
          Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? headers}) =>
      _send(() => _dio.delete(path,
          data: data,
          queryParameters: queryParameters,
          options: _options(headers)));

  Future<RestClientResponse<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      return RestClientResponse<T>(
        data: response.data as T?,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
      );
    } on DioException catch (e) {
      final response = e.response;
      final body = response?.data;
      throw RestClientException(
        message: body is Map ? body['message'] as String? : null,
        statusCode: response?.statusCode,
        error: e.error,
        response: RestClientResponse(
          data: body,
          statusCode: response?.statusCode,
          statusMessage: response?.statusMessage,
        ),
      );
    }
  }
}
