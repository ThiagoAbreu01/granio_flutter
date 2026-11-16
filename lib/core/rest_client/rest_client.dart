import 'package:granio_flutter/core/rest_client/rest_client_response.dart';

abstract class RestClient {
  /// Cliente para rotas autenticadas. Devolve uma **nova** instância: o flag
  /// vale só para as chamadas feitas a partir dela.
  RestClient auth();

  /// Cliente para rotas públicas (login, cadastro).
  RestClient unauth();

  Future<RestClientResponse<T>> get<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<RestClientResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });
}
