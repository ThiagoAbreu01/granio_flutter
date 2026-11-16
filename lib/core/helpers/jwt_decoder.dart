import 'dart:convert';

/// Lê o `exp` de um JWT **sem validar a assinatura** — só serve para o app
/// decidir quando renovar. Quem valida de verdade é o servidor.
DateTime? jwtExpiration(String token) {
  try {
    final raw = token.startsWith('Bearer ') ? token.substring(7) : token;
    final parts = raw.split('.');
    if (parts.length != 3) return null;
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final exp = (jsonDecode(payload) as Map<String, dynamic>)['exp'];
    if (exp is! int) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  } catch (_) {
    return null;
  }
}
