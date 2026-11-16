import 'package:granio_flutter/core/rest_client/rest_client_response.dart';

class RestClientException implements Exception {
  /// Mensagem do corpo (`{ "message": ... }`) quando o servidor manda uma.
  final String? message;

  /// `null` = sem resposta (offline, timeout).
  final int? statusCode;
  final dynamic error;
  final RestClientResponse response;

  const RestClientException({
    this.message,
    this.statusCode,
    required this.error,
    required this.response,
  });

  @override
  String toString() =>
      'RestClientException(message: $message, statusCode: $statusCode, error: $error)';
}
