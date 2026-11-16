import 'package:dio/dio.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/exceptions/session_expired_exception.dart';
import 'package:granio_flutter/core/helpers/constants.dart';
import 'package:granio_flutter/core/helpers/jwt_decoder.dart';
import 'package:granio_flutter/core/local_storage/secure_storage/i_secure_local_storage.dart';
import 'package:granio_flutter/core/logger/logger.dart';

/// Coloca o `Authorization` nas rotas autenticadas e mantém a sessão viva.
///
/// **Por que renovar antes de vencer:** no thtek_server, o `SecurityMiddleware`
/// valida a expiração do access token também em `/granio/auth/refresh`. Então o
/// refresh só funciona com o access token **ainda válido**. Os tokens do
/// servidor são: access = 24h; refresh = só passa a valer 12h depois de
/// emitido. Logo a janela de renovação é entre 12h e 24h de idade do access
/// token — é aí que este interceptor renova, antes da requisição sair.
///
/// Se o app ficar mais de 24h sem uso, o access vence, o refresh não é mais
/// aceito e o usuário precisa entrar de novo com e-mail e senha.
///
/// É `QueuedInterceptor`: requisições simultâneas passam uma de cada vez,
/// então só a primeira dispara o refresh.
class AuthInterceptor extends QueuedInterceptor {
  final ISecureLocalStorage _secureLocalStorage;
  final AuthStore _authStore;
  final Logger _log;
  final Dio _refreshDio;

  AuthInterceptor({
    required ISecureLocalStorage secureLocalStorage,
    required AuthStore authStore,
    required Logger log,
    required Dio refreshDio,
  })  : _secureLocalStorage = secureLocalStorage,
        _authStore = authStore,
        _log = log,
        _refreshDio = refreshDio;

  /// Abaixo disto de vida restante, renova (= token com mais de 12h).
  static const _janelaRenovacao = Duration(hours: 12);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authRequired =
        options.extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] == true;

    if (!authRequired) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    var accessToken = await _secureLocalStorage
        .read(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
    final expiracao = accessToken == null ? null : jwtExpiration(accessToken);

    if (accessToken == null ||
        (expiracao != null && expiracao.isBefore(DateTime.now()))) {
      await _expirarSessao();
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: SessionExpiredException(),
        ),
      );
    }

    if (expiracao != null &&
        expiracao.difference(DateTime.now()) < _janelaRenovacao) {
      accessToken = await _renovar(accessToken) ?? accessToken;
    }

    options.headers['Authorization'] = accessToken;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final authRequired =
        err.requestOptions.extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] ==
            true;

    // O SecurityMiddleware responde 403 + "Login Expirado." para token
    // inválido/expirado. Outros 403 são regra de negócio e passam direto.
    final data = err.response?.data;
    final tokenRecusado = err.response?.statusCode == 403 &&
        data is Map &&
        data['message'] == 'Login Expirado.';

    if (authRequired && tokenRecusado) {
      await _expirarSessao();
      return handler.next(err.copyWith(error: SessionExpiredException()));
    }
    handler.next(err);
  }

  /// Troca o par de tokens. Falha não derruba a sessão: o access atual ainda
  /// vale, e a próxima requisição tenta de novo.
  Future<String?> _renovar(String accessToken) async {
    final refreshToken = await _secureLocalStorage
        .read(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY);
    if (refreshToken == null) return null;

    try {
      final response = await _refreshDio.put<Map<String, dynamic>>(
        '${Constants.API_PREFIX}/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': accessToken}),
      );
      final novoAccess = response.data!['access_token'] as String;
      final novoRefresh = response.data!['refresh_token'] as String;

      await _secureLocalStorage.write(
          Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY, novoAccess);
      await _secureLocalStorage.write(
          Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY, novoRefresh);
      return novoAccess;
    } on DioException catch (e, s) {
      _log.warning('Não foi possível renovar o token agora.', e, s);
      return null;
    }
  }

  Future<void> _expirarSessao() async {
    await _secureLocalStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
    await _secureLocalStorage.remove(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY);
    await _secureLocalStorage.remove(Constants.LOCAL_STORAGE_BIOMETRIA_KEY);
    _authStore.limpar();
  }
}
