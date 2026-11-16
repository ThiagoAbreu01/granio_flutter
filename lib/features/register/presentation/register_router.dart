import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:granio_flutter/features/register/presentation/register_controller.dart';
import 'package:granio_flutter/features/register/presentation/register_page.dart';

class RegisterRouter {
  const RegisterRouter();

  Widget get page => Builder(
        builder: (context) => BlocProvider(
          create: (context) => RegisterController(
            authRepository: context.read<IAuthRepository>(),
            log: context.read<Logger>(),
          ),
          child: const RegisterPage(),
        ),
      );
}
