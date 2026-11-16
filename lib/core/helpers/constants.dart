// ignore_for_file: constant_identifier_names

class Constants {
  Constants._();

  //! .env
  static const ENV_BASE_URL_KEY = 'base_url';
  static const ENV_REST_CLIENT_CONNECT_TIMEOUT_KEY =
      'rest_client_connect_timeout';
  static const ENV_REST_CLIENT_RECEIVE_TIMEOUT_KEY =
      'rest_client_receive_timeout';

  //! Rest client
  static const REST_CLIENT_AUTH_REQUIRED_KEY = 'auth_required';

  /// Todas as rotas do app ficam sob o módulo `granio` do thtek_server.
  static const API_PREFIX = 'granio';

  //! Secure storage
  static const LOCAL_STORAGE_ACCESS_TOKEN_KEY = 'access_token';
  static const LOCAL_STORAGE_REFRESH_TOKEN_KEY = 'refresh_token';
  static const LOCAL_STORAGE_BIOMETRIA_KEY = 'biometria_habilitada';
}
