import 'package:granio_flutter/features/auth/domain/entities/register_data.dart';

abstract class IAuthRepository {
  /// Login + confirm, já guardando o par de tokens. Lança [Failure].
  Future<void> login(String email, String password);

  Future<void> register(RegisterData data);

  /// Apaga a sessão. Com biometria habilitada os tokens ficam, porque é
  /// eles que a digital libera no próximo acesso.
  Future<void> logout();

  Future<void> habilitarBiometria();

  /// Biometria habilitada, sessão guardada e sensor disponível.
  Future<bool> podeEntrarComBiometria();

  /// `true` = autenticou; `false` = usuário cancelou.
  /// Lança [FingerPrintException] nos demais casos.
  Future<bool> autenticarBiometria();
}
