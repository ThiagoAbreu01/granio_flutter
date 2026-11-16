import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:granio_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:granio_flutter/features/auth/data/datasources/biometric_data_source.dart';
import 'package:granio_flutter/features/auth/domain/entities/register_data.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';

/// Diferente dos outros repositórios (que só delegam), este orquestra três
/// datasources: a sequência de login e o armazenamento dos tokens são
/// infraestrutura e não devem ficar no controller.
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final BiometricDataSource _biometric;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required BiometricDataSource biometric,
  })  : _remote = remote,
        _local = local,
        _biometric = biometric;

  @override
  Future<void> login(String email, String password) async {
    final accessToken = await _remote.login(email, password);
    await _local.salvarAccessToken(accessToken);

    try {
      // O confirm devolve um access token NOVO, ao qual o refresh fica
      // amarrado. Guardar só o refresh quebraria a renovação.
      final confirm = await _remote.confirmLogin();
      await _local.salvarAccessToken(confirm.accessToken);
      await _local.salvarRefreshToken(confirm.refreshToken);
    } on Failure {
      await _local.limparTokens();
      rethrow;
    }
  }

  @override
  Future<void> register(RegisterData data) => _remote.register(data);

  @override
  Future<void> logout() async {
    if (!await _local.biometriaHabilitada) await _local.limparTokens();
  }

  @override
  Future<void> habilitarBiometria() async {
    if (await _biometric.isDisponivel()) {
      await _local.setBiometriaHabilitada(true);
    }
  }

  @override
  Future<bool> podeEntrarComBiometria() async =>
      await _local.biometriaHabilitada &&
      await _local.refreshToken != null &&
      await _biometric.isDisponivel();

  @override
  Future<bool> autenticarBiometria() => _biometric.autenticar();
}
