import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:granio_flutter/core/exceptions/failure.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/features/auth/domain/entities/register_data.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:granio_flutter/features/register/presentation/register_controller.dart';
import 'package:granio_flutter/features/register/presentation/register_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockLogger extends Mock implements Logger {}

void main() {
  late _MockAuthRepository authRepository;

  setUpAll(() => registerFallbackValue(const RegisterData(
        nome: '',
        email: '',
        password: '',
        confirmPassword: '',
      )));

  setUp(() => authRepository = _MockAuthRepository());

  RegisterController build() =>
      RegisterController(authRepository: authRepository, log: _MockLogger());

  blocTest<RegisterController, RegisterState>(
    'senhas diferentes: erro sem chamar o back',
    build: build,
    act: (c) => c.cadastrar(
      nome: 'Thiago',
      email: 'a@a.com',
      telefone: '',
      senha: '123456',
      confirmarSenha: '654321',
    ),
    expect: () => [
      const RegisterState(
        status: RegisterStatus.error,
        errorMessage: 'As senhas não conferem.',
      ),
    ],
    verify: (_) => verifyNever(() => authRepository.register(any())),
  );

  blocTest<RegisterController, RegisterState>(
    'normaliza os campos antes de enviar',
    setUp: () =>
        when(() => authRepository.register(any())).thenAnswer((_) async {}),
    build: build,
    act: (c) => c.cadastrar(
      nome: '  Thiago   Abreu ',
      email: ' A@A.COM ',
      telefone: '(11) 98888-7777',
      senha: '123456',
      confirmarSenha: '123456',
    ),
    expect: () => [
      const RegisterState(status: RegisterStatus.loading),
      const RegisterState(status: RegisterStatus.success),
    ],
    verify: (_) {
      final data = verify(() => authRepository.register(captureAny()))
          .captured
          .single as RegisterData;
      expect(data.nome, 'Thiago Abreu');
      expect(data.email, 'a@a.com');
      expect(data.telefone, '11988887777');
    },
  );

  blocTest<RegisterController, RegisterState>(
    'e-mail já cadastrado: mostra a mensagem do back',
    setUp: () => when(() => authRepository.register(any())).thenThrow(
      Failure(message: 'Já existe uma conta com esse e-mail.'),
    ),
    build: build,
    act: (c) => c.cadastrar(
      nome: 'Thiago',
      email: 'a@a.com',
      telefone: '',
      senha: '123456',
      confirmarSenha: '123456',
    ),
    expect: () => [
      const RegisterState(status: RegisterStatus.loading),
      const RegisterState(
        status: RegisterStatus.error,
        errorMessage: 'Já existe uma conta com esse e-mail.',
      ),
    ],
  );
}
