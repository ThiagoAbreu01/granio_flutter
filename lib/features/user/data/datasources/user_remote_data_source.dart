import 'package:granio_flutter/core/helpers/constants.dart';
import 'package:granio_flutter/core/helpers/json_decoder.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/core/rest_client/dio/dio_rest_client.dart';
import 'package:granio_flutter/core/rest_client/request_handler.dart';
import 'package:granio_flutter/features/user/domain/entities/user.dart';

class UserRemoteDataSource {
  final DioRestClient _dio;
  final Logger _log;

  const UserRemoteDataSource({
    required DioRestClient dio,
    required Logger log,
  })  : _dio = dio,
        _log = log;

  static const _base = '${Constants.API_PREFIX}/user';

  Future<User> getContaConectada() => handleRequest(
        () async {
          final result = await _dio.auth().get('$_base/');
          return User.fromMap(decodeMap(result.data));
        },
        log: _log,
        contexto: 'Erro ao obter informações da conta conectada.',
      );

  Future<String> deleteAccount(User contaConectada) => handleRequest(
        () async {
          final response = await _dio
              .auth()
              .delete('$_base/delete-account/${contaConectada.id}');
          return decodeMap(response.data)['message'] as String;
        },
        log: _log,
        contexto: 'Erro ao deletar conta.',
      );
}
