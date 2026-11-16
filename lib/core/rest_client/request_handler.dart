import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/core/exceptions/session_expired_exception.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/core/rest_client/rest_client_exception.dart';

/// Executa uma chamada de rede aplicando o tratamento de erro padrão do app:
/// loga a [RestClientException] e a converte em [Failure] com mensagem amigável.
///
/// Use nos `*RemoteDataSource` para não repetir try/catch em cada método:
/// ```dart
/// Future<User> getContaConectada() => handleRequest(
///       () async {
///         final res = await _dio.auth().get('${Constants.API_PREFIX}/user/');
///         return User.fromMap(decodeMap(res.data));
///       },
///       log: _log,
///       contexto: 'Erro ao obter conta conectada',
///     );
/// ```
Future<T> handleRequest<T>(
  Future<T> Function() request, {
  required Logger log,
  String? contexto,
}) async {
  try {
    return await request();
  } on RestClientException catch (e, s) {
    log.error(contexto ?? e.toString(), e, s);
    if (e.error is SessionExpiredException) throw e.error as Failure;
    if (e.statusCode == null) {
      throw Failure(message: 'Erro de conexão com o servidor.');
    }
    throw Failure(message: e.message ?? contexto);
  }
}
