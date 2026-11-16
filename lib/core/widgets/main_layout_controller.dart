import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';

/// Ações da casca da área logada (hoje: sair).
class MainLayoutController extends Cubit<void> {
  final IAuthRepository _authRepository;
  final AuthStore _authStore;

  MainLayoutController({
    required IAuthRepository authRepository,
    required AuthStore authStore,
  })  : _authRepository = authRepository,
        _authStore = authStore,
        super(null);

  /// Limpar o [AuthStore] dispara o redirect do GoRouter para /login.
  Future<void> sair() async {
    await _authRepository.logout();
    _authStore.limpar();
  }
}
