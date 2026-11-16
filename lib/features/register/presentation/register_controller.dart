import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/features/auth/domain/entities/register_data.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:granio_flutter/features/register/presentation/register_state.dart';

class RegisterController extends Cubit<RegisterState> {
  final IAuthRepository _authRepository;
  final Logger _log;

  RegisterController({
    required IAuthRepository authRepository,
    required Logger log,
  })  : _authRepository = authRepository,
        _log = log,
        super(const RegisterState());

  /// A validação de verdade (tamanho, formato do e-mail, e-mail repetido) é do
  /// back. Aqui só o guard de UX: campos obrigatórios e senhas iguais.
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String confirmarSenha,
  }) async {
    if (nome.trim().isEmpty || email.trim().isEmpty || senha.isEmpty) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Preencha nome, e-mail e senha.',
      ));
      return;
    }
    if (senha != confirmarSenha) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'As senhas não conferem.',
      ));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      final apenasDigitos = telefone.replaceAll(RegExp(r'\D'), '');
      await _authRepository.register(RegisterData(
        nome: nome.trim().replaceAll(RegExp(r'\s+'), ' '),
        email: email.trim().toLowerCase(),
        telefone: apenasDigitos.isEmpty ? null : apenasDigitos,
        password: senha,
        confirmPassword: confirmarSenha,
      ));
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e, s) {
      _log.error('Erro ao cadastrar.', e, s);
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: e is Failure
            ? (e.message ?? 'Falha ao criar conta.')
            : 'Falha ao criar conta.',
      ));
    }
  }
}
