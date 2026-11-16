import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/exceptions/invalid_credentials_exception.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:granio_flutter/features/login/presentation/login_controller.dart';
import 'package:granio_flutter/features/login/presentation/login_state.dart';
import 'package:granio_flutter/features/user/domain/entities/user.dart';
import 'package:granio_flutter/features/user/domain/repositories/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockUserRepository extends Mock implements IUserRepository {}

class _MockLogger extends Mock implements Logger {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockUserRepository userRepository;
  late AuthStore authStore;

  const user = User(id: 1, nome: 'Thiago Abreu', email: 'a@a.com');

  LoginController build() => LoginController(
        authRepository: authRepository,
        userRepository: userRepository,
        authStore: authStore,
        log: _MockLogger(),
      );

  setUp(() {
    authRepository = _MockAuthRepository();
    userRepository = _MockUserRepository();
    authStore = AuthStore();
  });

  group('realizarLogin', () {
    blocTest<LoginController, LoginState>(
      'campos vazios: erro sem chamar o repositório',
      build: build,
      act: (c) => c.realizarLogin(email: ' ', senha: ''),
      expect: () => [
        const LoginState(
          status: LoginStatus.error,
          errorMessage: 'Preencha todos os campos.',
        ),
      ],
      verify: (_) => verifyNever(() => authRepository.login(any(), any())),
    );

    blocTest<LoginController, LoginState>(
      'sucesso: normaliza o e-mail, guarda o usuário no AuthStore',
      setUp: () {
        when(() => authRepository.login(any(), any())).thenAnswer((_) async {});
        when(() => userRepository.getContaConectada())
            .thenAnswer((_) async => user);
      },
      build: build,
      act: (c) => c.realizarLogin(email: ' A@A.com ', senha: '123456'),
      expect: () => [
        const LoginState(status: LoginStatus.loading),
        const LoginState(status: LoginStatus.success, contaConectada: user),
      ],
      verify: (_) {
        verify(() => authRepository.login('a@a.com', '123456')).called(1);
        verifyNever(() => authRepository.habilitarBiometria());
        expect(authStore.usuarioLogado, user);
      },
    );

    blocTest<LoginController, LoginState>(
      'com "salvar biometria" marcado, habilita a biometria',
      setUp: () {
        when(() => authRepository.login(any(), any())).thenAnswer((_) async {});
        when(() => authRepository.habilitarBiometria()).thenAnswer((_) async {});
        when(() => userRepository.getContaConectada())
            .thenAnswer((_) async => user);
      },
      build: build,
      act: (c) => c.realizarLogin(
        email: 'a@a.com',
        senha: '123456',
        salvarBiometria: true,
      ),
      verify: (_) => verify(() => authRepository.habilitarBiometria()).called(1),
    );

    blocTest<LoginController, LoginState>(
      'credenciais inválidas: mostra a mensagem do back',
      setUp: () => when(() => authRepository.login(any(), any())).thenThrow(
        InvalidCredentialsException(message: 'E-mail ou senha inválidos.'),
      ),
      build: build,
      act: (c) => c.realizarLogin(email: 'a@a.com', senha: 'errada'),
      expect: () => [
        const LoginState(status: LoginStatus.loading),
        const LoginState(
          status: LoginStatus.error,
          errorMessage: 'E-mail ou senha inválidos.',
        ),
      ],
      verify: (_) => expect(authStore.isLogado, isFalse),
    );
  });

  group('biometria', () {
    blocTest<LoginController, LoginState>(
      'carregar sem biometria habilitada: só esconde o botão',
      setUp: () => when(() => authRepository.podeEntrarComBiometria())
          .thenAnswer((_) async => false),
      build: build,
      act: (c) => c.carregar(),
      expect: () => [const LoginState()],
      verify: (_) => verifyNever(() => authRepository.autenticarBiometria()),
    );

    blocTest<LoginController, LoginState>(
      'cancelar o prompt automático não mostra erro',
      setUp: () {
        when(() => authRepository.podeEntrarComBiometria())
            .thenAnswer((_) async => true);
        when(() => authRepository.autenticarBiometria())
            .thenAnswer((_) async => false);
      },
      build: build,
      act: (c) => c.carregar(),
      expect: () => [
        const LoginState(biometriaDisponivel: true),
        const LoginState(status: LoginStatus.loading, biometriaDisponivel: true),
        const LoginState(biometriaDisponivel: true),
      ],
    );

    blocTest<LoginController, LoginState>(
      'digital ok: busca a conta e entra',
      setUp: () {
        when(() => authRepository.autenticarBiometria())
            .thenAnswer((_) async => true);
        when(() => userRepository.getContaConectada())
            .thenAnswer((_) async => user);
      },
      build: build,
      act: (c) => c.entrarComBiometria(),
      expect: () => [
        const LoginState(status: LoginStatus.loading),
        const LoginState(status: LoginStatus.success, contaConectada: user),
      ],
    );
  });
}
