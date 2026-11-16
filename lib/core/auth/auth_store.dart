import 'package:flutter/foundation.dart';
import 'package:granio_flutter/features/user/domain/entities/user.dart';

/// Usuário logado em memória. O `GoRouter` escuta este store para proteger
/// as rotas e o `AuthInterceptor` o limpa quando a sessão expira.
class AuthStore extends ChangeNotifier {
  User? _usuarioLogado;

  User? get usuarioLogado => _usuarioLogado;
  bool get isLogado => _usuarioLogado != null;

  void setUsuario(User user) {
    _usuarioLogado = user;
    notifyListeners();
  }

  void limpar() {
    if (_usuarioLogado == null) return;
    _usuarioLogado = null;
    notifyListeners();
  }
}
