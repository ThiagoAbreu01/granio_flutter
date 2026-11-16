import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:granio_flutter/features/login/presentation/login_controller.dart';
import 'package:granio_flutter/features/login/presentation/login_page.dart';
import 'package:granio_flutter/features/user/domain/repositories/i_user_repository.dart';

class LoginRouter {
  const LoginRouter();

  Widget get page => Builder(
        builder: (context) => BlocProvider(
          create: (context) => LoginController(
            authRepository: context.read<IAuthRepository>(),
            userRepository: context.read<IUserRepository>(),
            authStore: context.read<AuthStore>(),
            log: context.read<Logger>(),
          )..carregar(),
          child: const LoginPage(),
        ),
      );
}
