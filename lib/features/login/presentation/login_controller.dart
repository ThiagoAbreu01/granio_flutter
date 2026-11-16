import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:granio_flutter/features/login/presentation/login_state.dart';
import 'package:granio_flutter/features/user/domain/repositories/i_user_repository.dart';

class LoginController extends Cubit<LoginState> {
  final IAuthRepository _authRepository;
  final IUserRepository _userRepository;
  final AuthStore _authStore;
  final Logger _log;

  LoginController({
    required IAuthRepository authRepository,
    required IUserRepository userRepository,
    required AuthStore authStore,
    required Logger log,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _authStore = authStore,
        _log = log,
        super(const LoginState());

  /// Mostra o botão de digital e, se houver sessão salva, já pede a biometria.
  Future<void> carregar() async {
    final disponivel = await _authRepository.podeEntrarComBiometria();
    if (isClosed) return;
    emit(state.copyWith(biometriaDisponivel: disponivel));
    if (disponivel) await entrarComBiometria(automatico: true);
  }

  Future<void> realizarLogin({
    required String email,
    required String senha,
    bool salvarBiometria = false,
  }) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Preencha todos os campos.',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _authRepository.login(email.trim().toLowerCase(), senha);
      if (salvarBiometria) await _authRepository.habilitarBiometria();
      await _carregarConta();
    } catch (e, s) {
      _emitErro(e, s, 'Falha ao realizar login.');
    }
  }

  /// [automatico]: disparado ao abrir a tela — cancelar o prompt não é erro.
  Future<void> entrarComBiometria({bool automatico = false}) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final autenticou = await _authRepository.autenticarBiometria();
      if (!autenticou) {
        emit(state.copyWith(
          status: automatico ? LoginStatus.initial : LoginStatus.error,
          errorMessage: automatico ? null : 'Autenticação cancelada.',
        ));
        return;
      }
      // O AuthInterceptor renova o token antes desta chamada, se precisar.
      await _carregarConta();
    } catch (e, s) {
      // Sessão vencida desliga a biometria: o botão some.
      final disponivel = await _authRepository.podeEntrarComBiometria();
      if (isClosed) return;
      emit(state.copyWith(biometriaDisponivel: disponivel));
      _emitErro(e, s, 'Falha ao entrar com biometria.');
    }
  }

  Future<void> _carregarConta() async {
    final user = await _userRepository.getContaConectada();
    _authStore.setUsuario(user);
    if (isClosed) return;
    emit(state.copyWith(status: LoginStatus.success, contaConectada: user));
  }

  void _emitErro(Object e, StackTrace s, String padrao) {
    _log.error(padrao, e, s);
    if (isClosed) return;
    emit(state.copyWith(
      status: LoginStatus.error,
      errorMessage: e is Failure ? (e.message ?? padrao) : padrao,
    ));
  }
}
