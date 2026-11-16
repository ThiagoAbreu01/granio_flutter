/// Par de tokens devolvido por `PATCH /granio/auth/confirm`.
///
/// O `accessToken` daqui é **novo** (não é o do login) e é a ele que o
/// `refreshToken` fica amarrado no servidor — os dois precisam ser guardados.
class ConfirmLogin {
  final String accessToken;
  final String refreshToken;

  const ConfirmLogin({required this.accessToken, required this.refreshToken});

  factory ConfirmLogin.fromMap(Map<String, dynamic> map) => ConfirmLogin(
        accessToken: map['access_token'] as String,
        refreshToken: map['refresh_token'] as String,
      );
}
