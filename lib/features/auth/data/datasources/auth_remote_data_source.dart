import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/core/exceptions/invalid_credentials_exception.dart';
import 'package:granio_flutter/core/helpers/constants.dart';
import 'package:granio_flutter/core/helpers/json_decoder.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/core/rest_client/dio/dio_rest_client.dart';
import 'package:granio_flutter/core/rest_client/request_handler.dart';
import 'package:granio_flutter/core/rest_client/rest_client_exception.dart';
import 'package:granio_flutter/features/auth/domain/entities/confirm_login.dart';
import 'package:granio_flutter/features/auth/domain/entities/register_data.dart';

class AuthRemoteDataSource {
  final DioRestClient _dio;
  final Logger _log;

  const AuthRemoteDataSource({
    required DioRestClient dio,
    required Logger log,
  })  : _dio = dio,
        _log = log;

  static const _base = '${Constants.API_PREFIX}/auth';

  /// Devolve o access token (já com `Bearer `).
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.unauth().post(
        '$_base/',
        data: {
          'email': email,
          'pass_crypto': password,
          'social_login': false,
        },
      );
      return decodeMap(response.data)['access_token'] as String;
    } on RestClientException catch (e, s) {
      _log.error('Erro ao realizar login.', e, s);
      if (e.statusCode == null) {
        throw Failure(message: 'Erro de conexão com o servidor.');
      }
      if (e.statusCode == 401) {
        throw InvalidCredentialsException(
          message: e.message ?? 'E-mail ou senha inválidos.',
        );
      }
      throw Failure(message: e.message ?? 'Erro ao realizar login.');
    }
  }

  Future<ConfirmLogin> confirmLogin() => handleRequest(
        () async {
          final response = await _dio.auth().patch('$_base/confirm');
          return ConfirmLogin.fromMap(decodeMap(response.data));
        },
        log: _log,
        contexto: 'Erro ao confirmar login.',
      );

  Future<void> register(RegisterData data) => handleRequest(
        () async {
          await _dio.unauth().post('$_base/register', data: data.toMap());
        },
        log: _log,
        contexto: 'Erro ao cadastrar usuário.',
      );
}
