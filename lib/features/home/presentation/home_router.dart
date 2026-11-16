import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/features/home/presentation/home_controller.dart';
import 'package:granio_flutter/features/home/presentation/home_page.dart';

class HomeRouter {
  const HomeRouter();

  Widget get page => Builder(
        builder: (context) => BlocProvider(
          create: (context) => HomeController(
            authStore: context.read<AuthStore>(),
            repository: context.read(),
            sync: context.read(),
          )..carregar(),
          child: const HomePage(),
        ),
      );
}
