// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/services.dart';
import 'package:granio_flutter/core/exceptions/finger_print_exception.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart' as auth_android;

/// Acesso ao sensor de biometria (`local_auth`).
class BiometricDataSource {
  final LocalAuthentication _auth;

  BiometricDataSource({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// `false` em plataformas sem plugin (Linux, web) ou sem biometria.
  Future<bool> isDisponivel() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> autenticar() async {
    if (!await isDisponivel()) {
      throw FingerPrintException(
        message: 'A biometria não está disponível neste dispositivo.',
      );
    }
    try {
      return await _auth.authenticate(
        localizedReason: 'Escaneie sua digital para continuar.',
        authMessages: const [
          auth_android.AndroidAuthMessages(
            cancelButton: 'Cancelar',
            signInTitle: 'Autenticação por biometria',
            biometricSuccess: 'Sucesso!',
            biometricNotRecognized: 'Biometria não reconhecida.',
            goToSettingsButton: 'Configurações',
          ),
        ],
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } on PlatformException catch (e) {
      throw FingerPrintException(message: _mensagem(e));
    }
  }

  String _mensagem(PlatformException e) => switch (e.code) {
        auth_error.lockedOut =>
          'Bloqueado temporariamente por muitas tentativas. Aguarde 30 segundos '
              'ou entre com e-mail e senha.',
        auth_error.permanentlyLockedOut =>
          'Biometria bloqueada. Bloqueie e desbloqueie o aparelho para tentar de novo.',
        auth_error.notAvailable ||
        auth_error.notEnrolled =>
          'Cadastre uma biometria nas configurações do aparelho.',
        auth_error.passcodeNotSet =>
          'Defina uma senha de bloqueio no aparelho para usar a biometria.',
        _ => e.message ?? 'Não foi possível usar a biometria.',
      };
}
