import 'package:granio_flutter/core/helpers/constants.dart';
import 'package:granio_flutter/core/local_storage/secure_storage/i_secure_local_storage.dart';

/// Sessão no armazenamento seguro. A senha do usuário **nunca** é guardada:
/// a biometria libera os tokens, não credenciais.
class AuthLocalDataSource {
  final ISecureLocalStorage _storage;

  const AuthLocalDataSource({required ISecureLocalStorage storage})
      : _storage = storage;

  Future<String?> get accessToken =>
      _storage.read(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);

  Future<String?> get refreshToken =>
      _storage.read(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY);

  Future<void> salvarAccessToken(String token) =>
      _storage.write(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY, token);

  Future<void> salvarRefreshToken(String token) =>
      _storage.write(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY, token);

  Future<bool> get biometriaHabilitada async =>
      await _storage.read(Constants.LOCAL_STORAGE_BIOMETRIA_KEY) == 'true';

  Future<void> setBiometriaHabilitada(bool valor) =>
      _storage.write(Constants.LOCAL_STORAGE_BIOMETRIA_KEY, '$valor');

  Future<void> limparTokens() async {
    await _storage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
    await _storage.remove(Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY);
  }
}
